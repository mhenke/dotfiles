import configparser
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
import xml.etree.ElementTree as ET


THEMES = Path(__file__).resolve().parents[1]
RENDERER = THEMES / 'lock-theme.py'
HOOK = THEMES.parent / 'hypr/.config/hypr/scripts/WallustSwww.sh'


class LockThemeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.script = self.home / 'dotfiles/sddm-themes/lock-theme.py'
        self.catalog = self.script.parent / 'simple-sddm/configs'
        self.catalog.mkdir(parents=True)
        if RENDERER.exists():
            shutil.copy2(RENDERER, self.script)
        self.bin = self.home / 'bin'
        self.bin.mkdir()
        self.executable('date', '#!/bin/sh\nexec /bin/date -u -d "2026-11-16 11:49:20 UTC" "$@"\n')
        self.env = dict(os.environ, HOME=str(self.home), PATH=str(self.bin) + os.pathsep + os.environ['PATH'])
        self.active = self.home / '.config/hypr/UserConfigs/hyprlock-theme.conf'
        self.entry('staircase', 'Staircase.png', ('#F1DA83', '#ED93FF', '#E3C399'), 50, 50, 50)
        self.entry('north', 'Northern Lights2.jpg', ('#ECF8FF', '#70F0A4', '#D9BDFF'), 25, 20, 25)
        self.entry('other', 'Other.png', ('#FFD18A', '#ADDDF2', '#F5EFDF'), 74, 30, 80)

    def executable(self, name, body):
        path = self.bin / name
        path.write_text(body)
        path.chmod(0o755)

    def entry(self, slug, filename, colors, x, y, unlock):
        path = self.catalog / f'theme-{slug}.conf'
        path.write_text(f'''[General]
Background="Backgrounds/{filename}"
[Lock]
HourColor="{colors[0]}"
MinuteColor="{colors[1]}"
SecondColor="{colors[2]}"
ClockX="{x}"
ClockY="{y}"
UnlockX="{unlock}"
''')
        return path

    def select(self, filename):
        return subprocess.run([sys.executable, str(self.script), str(self.home / filename)], env=self.env, capture_output=True, text=True)

    def clock_markup(self):
        include = self.active.read_text()
        lines = [line.strip() for line in include.splitlines()]
        value = next(line.split('=', 1)[1].strip() for line in lines if line.startswith('text ='))
        command = value.split(']', 1)[1].strip()
        result = subprocess.run(['/bin/sh', '-c', command.replace('##', '#')], env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.strip()

    def rendered_clock(self):
        root = ET.fromstring('<clock>' + self.clock_markup() + '</clock>')
        return [(span.text, span.attrib.get('foreground')) for span in root if span.text and span.text.strip()]

    def clock_position(self):
        line = next(line.strip() for line in self.active.read_text().splitlines() if line.strip().startswith('position ='))
        return tuple(float(value.strip().rstrip('%')) for value in line.split('=', 1)[1].split(','))

    def welcome_markup(self):
        texts = [line.split('=', 1)[1].strip() for line in self.active.read_text().splitlines() if line.strip().startswith('text =')]
        self.assertEqual(len(texts), 2, 'Expected a clock and a welcome label')
        return texts[1].replace('##', '#')

    def test_welcome_is_literal_text_not_a_command_or_markup(self):
        path = self.catalog / 'theme-staircase.conf'
        for header in ('COFFEE & COMMITS', 'cmd[update:1000] echo "hello" <b>#$USER $TIME</b>\nROOTED IN CODE'):
            with self.subTest(header=header):
                config = configparser.ConfigParser(interpolation=None)
                config.optionxform = str
                config.read(path)
                config['General']['HeaderText'] = header
                with path.open('w') as handle:
                    config.write(handle)
                result = self.select('Staircase.png')
                self.assertEqual(result.returncode, 0, result.stderr)
                markup = self.welcome_markup()
                self.assertTrue(markup.startswith('<span>'))
                self.assertNotIn('$', markup, 'Hyprlock must not expand header variables')
                self.assertEqual(''.join(ET.fromstring(markup).itertext()), header)

    def test_blank_header_keeps_the_clock_without_a_welcome_label(self):
        result = self.select('Staircase.png')
        self.assertEqual(result.returncode, 0, result.stderr)
        texts = [line for line in self.active.read_text().splitlines() if line.strip().startswith('text =')]
        self.assertEqual(len(texts), 1)
        self.assertEqual(self.rendered_clock()[0], ('11', '#F1DA83'))

    def test_spaced_filename_and_switch_back_restore_the_selected_clock(self):
        cases = [
            ('Northern Lights2.jpg', (-25, 30), ['#ECF8FF', '#70F0A4', '#D9BDFF']),
            ('Other.png', (24, 20), ['#FFD18A', '#ADDDF2', '#F5EFDF']),
            ('Northern Lights2.jpg', (-25, 30), ['#ECF8FF', '#70F0A4', '#D9BDFF']),
        ]
        for filename, position, colors in cases:
            with self.subTest(filename=filename):
                result = self.select(filename)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.clock_position(), position)
                self.assertEqual(self.rendered_clock(), list(zip(('11', '49', '20'), colors)))

    def test_unlisted_wallpaper_resets_the_previous_layout(self):
        self.assertEqual(self.select('Northern Lights2.jpg').returncode, 0)
        result = self.select('Unlisted.png')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.clock_position(), (0, 0))
        self.assertEqual(self.rendered_clock(), [('11', '#F1DA83'), ('49', '#ED93FF'), ('20', '#E3C399')])

    def test_invalid_known_theme_leaves_the_last_valid_lock_intact(self):
        result = self.select('Northern Lights2.jpg')
        self.assertEqual(result.returncode, 0, result.stderr)
        before = self.active.read_bytes()
        for field, bad_value in [('HourColor', '#FF0000; touch injected'), ('ClockX', 'NaN'), ('ClockY', '101')]:
            with self.subTest(field=field):
                path = self.entry('other', 'Other.png', ('#FFD18A', '#ADDDF2', '#F5EFDF'), 74, 30, 80)
                lines = path.read_text().splitlines()
                path.write_text('\n'.join(f'{field}="{bad_value}"' if line.startswith(field + '=') else line for line in lines) + '\n')
                result = self.select('Other.png')
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.active.read_bytes(), before)

    def test_wallpaper_hook_keeps_lock_matching_even_when_palette_generation_fails(self):
        for directory in ('.cache/swww', '.config/rofi', '.config/hypr/wallpaper_effects'):
            (self.home / directory).mkdir(parents=True)
        wallpaper = self.home / 'Northern Lights2.jpg'
        wallpaper.write_bytes(b'isolated image fixture; palette backend is external')
        (self.home / '.cache/swww/eDP-1').write_text(str(wallpaper) + '\n')
        self.executable('hyprctl', '#!/bin/sh\nprintf "Monitor eDP-1\\n    focused: yes\\n"\n')
        self.executable('wallust', '#!/bin/sh\nexit 1\n')
        result = subprocess.run(['/bin/bash', str(HOOK)], env=self.env, capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.home / '.config/hypr/wallpaper_effects/.wallpaper_current').read_bytes(), wallpaper.read_bytes())
        self.assertEqual(self.clock_position(), (-25, 30))
        self.assertEqual(self.rendered_clock(), [('11', '#ECF8FF'), ('49', '#70F0A4'), ('20', '#D9BDFF')])


    def test_unrelated_malformed_catalog_entry_is_not_selected(self):
        (self.catalog / 'theme-aaa-broken.conf').write_text('[General]\nBackground="One.png"\nBackground="Two.png"\n')
        result = self.select('Northern Lights2.jpg')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.rendered_clock(), [('11', '#ECF8FF'), ('49', '#70F0A4'), ('20', '#D9BDFF')])

    def test_hook_rejects_unusable_wallpaper_state(self):
        for directory in ('.cache/swww', '.config/rofi', '.config/hypr/wallpaper_effects'):
            (self.home / directory).mkdir(parents=True)
        wallpaper = self.home / 'Northern Lights2.jpg'
        wallpaper.write_bytes(b'isolated wallpaper fixture')
        cache = self.home / '.cache/swww/eDP-1'
        pointer = self.home / '.config/rofi/.current_wallpaper'
        self.executable('wallust', '#!/bin/sh\nexit 0\n')
        self.assertEqual(self.select(wallpaper.name).returncode, 0)
        cases = [('missing-cache', None), ('empty-cache', ''), ('missing-image', str(self.home / 'Missing.jpg')), ('pointer-directory', str(wallpaper)), ('missing-monitor', str(wallpaper))]
        for case, cached in cases:
            with self.subTest(case=case):
                cache.unlink(missing_ok=True)
                pointer.unlink(missing_ok=True)
                if cached is not None:
                    cache.write_text(cached + '\n')
                if case == 'pointer-directory':
                    pointer.mkdir()
                self.executable('hyprctl', '#!/bin/sh\nexit 0\n' if case == 'missing-monitor' else '#!/bin/sh\nprintf "Monitor eDP-1\\n    focused: yes\\n"\n')
                before = self.active.read_bytes()
                result = subprocess.run(['/bin/bash', str(HOOK)], env=self.env, capture_output=True, text=True)
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertEqual(self.active.read_bytes(), before)
            if pointer.is_dir() and not pointer.is_symlink():
                shutil.rmtree(pointer)

    def test_real_catalog_selects_each_declared_wallpaper(self):
        shutil.rmtree(self.catalog)
        shutil.copytree(THEMES / 'simple-sddm/configs', self.catalog)
        seen = set()
        for path in sorted(self.catalog.glob('theme-*.conf')):
            with self.subTest(theme=path.name):
                config = configparser.ConfigParser(interpolation=None)
                config.read(path)
                filename = Path(config['General']['Background'].strip('"')).name
                self.assertNotIn(filename, seen)
                seen.add(filename)
                self.assertTrue((THEMES / 'simple-sddm/Backgrounds' / filename).is_file())
                result = self.select(filename)
                self.assertEqual(result.returncode, 0, result.stderr)
                colors = [config['Lock'][role].strip('"') for role in ('HourColor', 'MinuteColor', 'SecondColor')]
                self.assertEqual(self.rendered_clock(), list(zip(('11', '49', '20'), colors)))
                header = config['General']['HeaderText'].strip('"')
                self.assertEqual(''.join(ET.fromstring(self.welcome_markup()).itertext()), header)

    def test_real_catalog_clocks_fit_the_reference_screen(self):
        try:
            import gi
            import cairo
            gi.require_version('Pango', '1.0')
            gi.require_version('PangoCairo', '1.0')
            from gi.repository import Pango, PangoCairo
        except (ImportError, ValueError) as error:
            self.skipTest(f'Native text rendering unavailable: {error}')

        shutil.rmtree(self.catalog)
        shutil.copytree(THEMES / 'simple-sddm/configs', self.catalog)
        context = cairo.Context(cairo.ImageSurface(cairo.FORMAT_ARGB32, 1, 1))
        screen_width, screen_height = 1920, 1200
        for path in sorted(self.catalog.glob('theme-*.conf')):
            with self.subTest(theme=path.name):
                config = configparser.ConfigParser(interpolation=None)
                config.read(path)
                filename = Path(config['General']['Background'].strip('"')).name
                self.assertEqual(self.select(filename).returncode, 0)
                lines = [line.strip() for line in self.active.read_text().splitlines()]
                family = next(line.split('=', 1)[1].strip() for line in lines if line.startswith('font_family ='))
                size = next(line.split('=', 1)[1].strip() for line in lines if line.startswith('font_size ='))
                layout = PangoCairo.create_layout(context)
                PangoCairo.context_set_resolution(layout.get_context(), 96)
                layout.set_font_description(Pango.FontDescription(f'{family} {size}'))
                layout.set_markup(self.clock_markup(), -1)
                width, height = layout.get_pixel_size()
                x, y = self.clock_position()
                center_x = screen_width * (0.5 + x / 100)
                center_y = screen_height * (0.5 - y / 100)
                self.assertGreaterEqual(center_x - width / 2, 0, 'Clock clips the left edge')
                self.assertGreaterEqual(center_y - height / 2, 0, 'Clock clips the top edge')
                self.assertLessEqual(center_x + width / 2, screen_width, 'Clock clips the right edge')
                self.assertLessEqual(center_y + height / 2, screen_height, 'Clock clips the bottom edge')


if __name__ == '__main__':
    unittest.main()
