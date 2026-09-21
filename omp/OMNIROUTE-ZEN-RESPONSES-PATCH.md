# OmniRoute local patch: zen GPT-5.6 family → Responses API

> Applied 2026-09-19. Remove this file once upstream #14230 merges and the
> installed omniroute includes it.

## Problem

OpenCode Zen serves `gpt-5.6-luna` (and `gpt-5.6-sol` / `gpt-5.6-terra`) only
on `/v1/responses`. Chat-completions requests get
`503 "Upstream request failed: Endpoint is unavailable."` — confirmed by
calling both zen endpoints directly with the same key. OpenCode's own CLI
works because its SDK uses `/responses`.

OmniRoute's static registry (`open-sse/config/providers/registry/opencode/zen/index.ts`)
tags `muse-spark-1.2` with `targetFormat: "openai-responses"` but never tagged
the GPT-5.6 entries, so `OpencodeExecutor.buildUrl()` posts them to
`/chat/completions`. (#12196 fixed the same gap for luna on opencode-go.)

## Local hotfix

Patched 9 compiled runtime chunks under
`~/.npm-global/lib/node_modules/omniroute/dist/` (`.build/next/server/chunks/*`
and `ssr/*`): added `targetFormat:"openai-responses"` to the
`{id:"gpt-5.6-luna",name:"GPT 5.6 Luna"}` registry object in each zen-scoped
copy. Originals kept next to them as `*.luna-bak` (gone after any omniroute
update).

Upstream tracking:

- Issue: https://github.com/diegosouzapw/OmniRoute/issues/14229
- PR: https://github.com/diegosouzapw/OmniRoute/pull/14230
- Related: #12196 (opencode-go side), muse-spark precedent #10874/#11046

## Re-apply after an omniroute update (if the PR is not merged yet)

```bash
python3 - <<'EOF'
import re, glob
files = glob.glob('/home/mhenke/.npm-global/lib/node_modules/omniroute/dist/**/[!]*.js', recursive=True)
old = '{id:"gpt-5.6-luna",name:"GPT 5.6 Luna"}'
new = '{id:"gpt-5.6-luna",name:"GPT 5.6 Luna",targetFormat:"openai-responses"}'
for f in files:
    s = open(f, encoding='utf-8', errors='ignore').read()
    if old in s and 'opencode.ai/zen/v1' in s:
        open(f, 'w').write(s.replace(old, new))
        print('patched', f)
EOF
```

Then restart the omniroute server. DB custom entry
(`customModels[opencode-zen]` → `gpt-5.6-luna`, `apiFormat: "responses"`) also
exists from debugging; harmless, not required for the fix.

## Verify

```bash
curl -s http://localhost:20128/v1/chat/completions -H "Authorization: Bearer $OMNIROUTE_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"model":"opencode-zen/gpt-5.6-luna","messages":[{"role":"user","content":"say ok"}],"max_tokens":600}'
```

Expect HTTP 200. Rule of thumb from this incident: `omniroute test` only checks
the provider connection — a bogus model name still reports success. Verify
slots with real requests (see OMNIROUTE-COMBOS.md Definitions).
