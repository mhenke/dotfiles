# Claude-Mem Memory Context

<claude-mem-context>
# Memory Context from Past Sessions

# Integration setup
- OpenCode → claude-mem bridge via `claude-mem.js` plugin (ports 37700)
- claude-mem worker runs as systemd user service (Type=simple, Restart=always)
- OpenRouter is the LLM provider for memory compression (CLAUDE_MEM_PROVIDER=openrouter in settings.json)
- chroma-mcp uses MCP stdio via uvx, provides vector search backend
- chroma-mcp 0.2.6 started via `chroma-mcp@0.2.6` (uvx uses `@`, not `==`)
- `openrouter` is in OpenCode's `disabled_providers`; `opencode` provider proxies models through OpenRouter

# System architecture
- Worker: `/home/mhenke/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs` (minified ~51KB, run by bun)
- Settings: `/home/mhenke/.claude-mem/settings.json`
- Database: `/home/mhenke/.claude-mem/claude-mem.db`
- Chroma data: `/home/mhenke/.claude-mem/chroma/`
- Systemd service: `~/.config/systemd/user/claude-mem.service`
- Plugin: `/home/mhenke/.config/opencode/plugins/claude-mem.js` (minified 335KB)
- Config: `/home/mhenke/.config/opencode/opencode.jsonc`
- Python: 3.13.1 via uv at `/home/mhenke/.local/share/uv/python/cpython-3.13.1-linux-x86_64-gnu/bin/python3.13`

# CLI
```bash
systemctl --user restart claude-mem   # restart after config changes
systemctl --user status claude-mem    # check if running
npx claude-mem search "<query>"       # semantic search via chroma
npx claude-mem doctor                 # verify all components healthy
curl localhost:37700/health           # HTTP health endpoint
```

# Key details
- Port 37700 = 37700 + (uid % 100) base
- chroma-mcp connects lazily on first search (ChromaMcpManager)
- uvx rejects `==` package version syntax — always use `@`
- The worker bundle was patched: `chroma-mcp==${WD}` → `chroma-mcp@${WD}` (two occurrences)
- No search results yet — database is fresh, no content stored
</claude-mem-context>
