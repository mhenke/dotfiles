# OmniRoute Combos — How to Update

How to change the per-agent-role model fallback chains ("combos") that omp/OMOS reference as `omniroute/<role>`.

## Where the chains live

**Not in dotfiles.** The `omniroute/*` ids in `omp/.omp/agent/config.yml` and `omp/.omp/agent/models.yml` are just provider handles. The actual chains are server state in OmniRoute's SQLite DB (`~/.omniroute/storage.sqlite`) and must be edited through OmniRoute's API — never hand-edit the DB.

- Chain source of truth: `omniroute api combos get-api-combos`
- Live model catalog (what ids actually exist right now):
  ```bash
  curl -s -H "Authorization: Bearer $(jq -r '.apiKey' ~/dotfiles/omp/.omp/agent/models.yml 2>/dev/null || echo $OMNIROUTE_API_KEY)" \
    http://localhost:20128/v1/models | jq -r '.data[].id' | sort -u
  ```
  API key also lives in `omp/.omp/agent/models.yml` under `providers.omniroute.apiKey`.

## Update procedure

### 1. Dump current combos

```bash
omniroute -q --output json api combos get-api-combos > /tmp/combos.json
tail -n +2 /tmp/combos.json > /tmp/combos.clean.json   # CLI prepends an env banner line
python3 -c "
import json
for c in json.load(open('/tmp/combos.clean.json'))['combos']:
    print(c['name'], c['id'], '->', ' | '.join(m['model'] for m in c['models']))
"
```

### 2. Write an update body

Keep the existing `id`, `strategy`, `config`, `isHidden`, `sortOrder`; replace `models`. Model entry shape:

```json
{
  "id": "<combo>-model-<n>-<slug>",   // unique inside the combo, free-form
  "kind": "model",
  "model": "<provider>/<model-id>",   // must exist in the live /v1/models catalog
  "providerId": "<provider>",         // first path segment of model
  "weight": 0
}
```

`strategy: "priority"` = ordered failover (top down). `strategy: "weighted"` = weighted pick — `static-best-free` uses this.
### 3. Apply

```bash
omniroute api combos put-api-combos-id- --id "<uuid>" --body @/tmp/omniroute-combos/fixer.json
```

### 4. Verify

```bash
# Read-back
omniroute -q --output json api combos get-api-combos | tail -n +2 | \
  python3 -c "import json,sys; [print(c['name'],'->',' | '.join(m['model'] for m in c['models'])) for c in json.load(sys.stdin)['combos']]"

# Smoke test: response `.model` shows which chain member actually served
curl -s -X POST http://localhost:20128/v1/chat/completions \
  -H "Authorization: Bearer $OMNIROUTE_API_KEY" -H "Content-Type: application/json" \
  -d '{"model":"<combo-name>","messages":[{"role":"user","content":"Reply with exactly: ok"}],"max_tokens":10}' | jq -r '.model // .error.message'
```

### 5. Probe individual members (optional)

Direct calls against single model ids reveal dead/auth-gated entries before they cost you a fallback hop:

```bash
curl -s -X POST http://localhost:20128/v1/chat/completions \
  -H "Authorization: Bearer $OMNIROUTE_API_KEY" -H "Content-Type: application/json" \
  -d '{"model":"opencode-zen/big-pickle","messages":[{"role":"user","content":"say ok"}],"max_tokens":5}'
```

HTTP codes that mean "prune or ignore": `401` provider gone, `402` needs API key, `403` gated (see below), `404` unknown id. `429` = alive, just rate-limited.

## Chain-Structure Protocol (Balanced Preset)

Framework for model hierarchies in agent chains — reliability + cost efficiency. Free models absorb basic load (cost-saving), paid models are reliable anchors. Council/skeptic blocks mirror their agent lists.

### Rules

Applies to balanced preset agents, council balanced presets α/β/γ, `agents.council`, `agents.skeptic`.

1. **Max one non-free `cmd/` (CommandCode) model per chain.** `cmd/` has multiple free models (Laguna S 2.1, Ling 3.0 Flash Sante, LongCat 2.0 — all `:free` tier) plus paid ones (deepseek-v4-flash, qwen3.7-plus, mimo-v2.5-pro, etc.). Stack free cmd/ models as deep cushion, but only ONE non-free cmd/ per chain — a second paid cmd/ won't save you from a CommandCode outage, it just burns budget.
2. **Paid `cmd/` must precede the final anchor** (unless it IS the final anchor). Paid tiers must fire before the final paygo, or you're not using what you pay for.
3. **Last entry must be `cmd/deepseek-*` (DeepSeek subscription) or `opencode-zen/` non-free paygo.** Not `nv/`, not `opencode-go/`, not `cline-pass/`, not free. Guarantees a stable, reliable final fallback.
4. **Free models front, paid models back.** Free tier (any provider) absorbs basic load first; paid tiers saved for hard fallbacks. Multiple `cmd/` free entries allowed as long as they precede any paid one. **Rationale:** free models are unreliable (rate limits, downtime, changing terms, stealth-model identity drift) — front-loading them is a cost-saving measure, not a reliability play. Paid tiers (DeepSeek, opencode-zen) have provider SLAs and are the anchors.
5. **`nvidia/` free models (NIM previews) allowed in the free-cushion front slot only.** Zero paid `nvidia/` models — paid nv/ costs money with no reliability advantage over DeepSeek/zen anchors.
6. **Council/agent blocks mirror the balanced preset exactly:** `agents.council` → orchestrator list. `agents.skeptic` → oracle list. `council.presets.balanced.alpha` → oracle list.

### Definitions / scope

1. "Free" = any `*:free` model + `opencode/big-pickle` + nvidia NIM previews. Active Zen free lineup (per Zen site, 2026-09-17): `big-pickle`, `union-alpha`, `mimo-v2.5-free`, `ling-3.0-flash-fin-free`, `nemotron-3-ultra-free`, `nemotron-3.5-lightning-free`, `muse-spark-1.3-contributor-free`. (1.2 contributor is superseded by 1.3; the stray `deepseek-v4-flash-free` id still exists in the omniroute catalog but is off the Zen site list. `union-alpha` uses Anthropic-style `/v1/messages`, muse-spark-1.3 uses OpenAI `/v1/responses` upstream — the only two non-chat-completions endpoints on Zen free tier. `opencode-zen/muse-spark-1.3-contributor-free` returned 500 on probes 2026-09-17 — upstream issue, kept but watch it.)
2. "Chain" = model + `fallback_models`, in order.
3. Rules exclude `nvidia-free` and `opencode-zen-free` presets — intentionally single-provider playgrounds.

### Resource dynamics

1. `cmd/` is a flat subscription lane (monthly fee), `opencode-go/`/`cline-pass/` are subscription quotas with shared pools ($60/mo Go, $70/mo GOAT), `opencode-zen/` is pay-per-token. Shift high-concurrency load to free cushions to avoid burning paid tiers on easy tasks.
2. Model diversity in a chain buys only transient fault tolerance (rate limits, timeouts) — no compounding cognitive benefit on single-turn calls. Keep chains short; excess nesting adds latency and risks orphaned subagent recoveries the parent orchestrator already timed out on.

### OmniRoute layering (how these rules map to omniroute combos)

Free cushions from **all** providers sit front (zen → cmd → openrouter), then the NVIDIA NIM layer, then the single paid `cmd/` model, then the DeepSeek/opencode-zen final anchor. Duplicate models across providers are intentional — same model via a second lane = transient-fault tolerance, not redundancy to prune. Overlap (e.g. nemotron-3-ultra on zen AND openrouter) is a feature: free is free.

Example body:

```json
{
  "name": "fixer",
  "id": "<uuid from step 1>",
  "strategy": "priority",
  "config": {},
  "isHidden": false,
  "sortOrder": 8,
  "models": [
    { "id": "fixer-model-1-a", "kind": "model", "model": "opencode-zen/nemotron-3.5-lightning-free", "providerId": "opencode-zen", "weight": 0 },
    { "id": "fixer-model-2-b", "kind": "model", "model": "cmd/z-ai/glm-5.3-flash", "providerId": "cmd", "weight": 0 }
  ]
}
```

## Known gotchas (2026-09-17)

- **OpenCode free models are gate-locked to the OpenCode CLI at the SERVER — confirmed at source 2026-09-17.** OmniRoute ships TWO OpenCode lanes: `opencode` (`oc`, no-auth public endpoint) and `opencode-zen` (API key). BOTH now 403 on free models with `FreeTierError "OpenCode's free tier can only be used from within OpenCode"` — tested with a valid Zen key, with no key (no-auth lane), and with CLI headers replicated (`x-opencode-client/session/request/project`, UA). The gate is evaluated server-side per request; only the OpenCode CLI's own session binding passes it. Consequence: `oc/*` and `zen *-free` ids are dead weight in omniroute combos — do NOT front-load them; keep `oc` in blockedProviders. Custom model entries for the free ids are already registered on the zen connection, so if the gate ever lifts they light up with no reconfig.
- **Zen paid lane + omniroute gotcha:** omniroute's zen connection needs the FULL Zen key. A truncated/partial key silently yields `402 "requires an opencode API key"` at request time while `test-connection` still reports what looks like success. If zen suddenly 402s in omniroute: (1) GET `/api/providers/client`, compare stored `apiKey` length against the real key in `~/.local/share/opencode/auth.json` (`opencode.key`), (2) PATCH `/api/providers/<conn-id>` with the full key, (3) POST `/api/providers/<conn-id>/test` until `testStatus: active`. 2026-09-17: fixed exactly this — omniroute had a stale 20-char key; restored a full 67-char key and paid zen models (e.g. `opencode-zen/glm-5.3-flash`, `opencode-zen/qwen3.6-plus`) returned to 200. **A freshly minted Zen key was tested the same day: paid 200, free models still `403 FreeTierError` — the free-tier CLI-only gate applies to every API key, new or old.**
- **NVIDIA NIM added Z.ai free endpoints (2026-09-16)**: `nvidia/z-ai/glm-5.3` (753B text MoE, sparse attention, reasoning+tools) and `nvidia/z-ai/glm-5.3-flash` (320B/18B-active multimodal). Probed 2026-09-17: glm-5.3 → 200; glm-5.3-flash → 000/504 (endpoint live in catalog but unstable via omniroute — retry before trusting).
- **`nvidia/deepseek-ai/deepseek-v4-flash-0731` deprecated upstream** (per NVIDIA, removal pending). Removed from static-best-free 2026-09-17, replaced by `nvidia/z-ai/glm-5.3`. (deepseek-v4-pro-0813 still live, kept.)
- **CommandCode free tier works from omniroute**: `cmd/meituan/LongCat-2.0:free`, `cmd/inclusionai/ling-3.0-flash-sante:free` → 200; `cmd/poolside/laguna-s-2.1-free` → 429 under load but alive.
- **No new combo id? Nothing to refresh downstream.** omp (`models.yml`) and opencode (`opencode.json`) declare combo ids statically; chain *contents* resolve at request time. Only if you create/rename a combo id do clients need updating (`omniroute setup-opencode` regenerates the opencode provider block; add the id to `omp/.omp/agent/models.yml` by hand).

## Combo inventory (2026-09-17, zen-free-lanes-cleansed)



**Zen connection custom models:** big-pickle, union-alpha, mimo-v2.5-free, ling-3.0-flash-fin-free, nemotron-3-ultra-free, nemotron-3.5-lightning-free, muse-spark-1.3-contributor-free — added so the ids are addressable for routing and auto-documented; all still 403 live (CLI gate). Stale builtin entries (hy3-free, deepseek-v4-flash-free, muse-spark-1.2*) remain in omniroute's builtin list but are dead upstream.

## Combo inventory (2026-09-17, zen-free-lanes-cleansed)

Each model on its own row so the provider lane is explicit — bare model ids are ambiguous (e.g. `mimo-v2.5-free` exists on both `opencode-zen` and `cmd`).

| combo | slot | provider | model | tier | notes |
|---|---|---|---|---|---|
| skeptic | 1 | or | nvidia/nemotron-3-ultra-550b-a55b:free | free | 550B-A55B MoE |
| skeptic | 2 | cmd | Qwen/Qwen3.7-Plus | paid | primary paid |
| skeptic | 3 | zen | qwen3.6-plus | paid | terminal anchor |
| orchestrator | 1 | cmd | meituan/LongCat-2.0:free | free | 2.0 flash, high tool-call |
| orchestrator | 2 | or | nvidia/nemotron-3-super-120b-a12b:free | free | 120B-A12B agentic |
| orchestrator | 3 | nvidia | nvidia/nemotron-3-super-120b-a12b | free | NIM preview (same model, second lane) |
| orchestrator | 4 | nvidia | nvidia/nemotron-3.5-lightning-30b-a3b | free | Terminal-Bench 2.1 24.58 — weak |
| orchestrator | 5 | cmd | Qwen/Qwen3.8-Flash | paid | SWE-bench Pro 62.5, GPQA 91.7 |
| orchestrator | 6 | cmd | deepseek/deepseek-v4-flash | paid | Terminal-Bench 2.1 82.7 |
| orchestrator | 7 | cmd | deepseek/deepseek-v4.1-flash | paid | Terminal-Bench 2.1 90.6 — terminal anchor |
| oracle | 1 | or | nvidia/nemotron-3-ultra-550b-a55b:free | free | GPQA 87.9 |
| oracle | 2 | nvidia | moonshotai/kimi-k3 | paid | deep reasoning |
| oracle | 3 | nvidia | deepseek-ai/deepseek-v4-pro-0813 | paid | audit-grade |
| oracle | 4 | cmd | meta/muse-spark-1.3-contributor | paid | reasoning specialist |
| oracle | 5 | cmd | xiaomi/mimo-v2.5-pro | paid | terminal anchor |
| designer | 1 | or | thinkingmachines/inkling-small:free | free | multimodal reasoning |
| designer | 2 | cmd | z-ai/glm-5.3-flash | paid | multimodal 320B/18B |
| designer | 3 | cmd | meta/muse-spark-1.3-contributor | paid | vision-capable |
| designer | 4 | nvidia | moonshotai/kimi-k3 | paid | |
| designer | 5 | cmd | deepseek/deepseek-v4-flash-vision-exp | paid | vision-terminated anchor |
| librarian | 1 | cmd | inclusionai/ling-3.0-flash-sante:free | free | health-tuned |
| librarian | 2 | or | inclusionai/ling-3.0-flash-fin:free | free | finance-tuned |
| librarian | 3 | or | dots-studio/dots-3-note-preview:free | free | 280B MoE, 512K ctx |
| librarian | 4 | cmd | Qwen/Qwen3.7-Flash | paid | |
| librarian | 5 | cmd | xiaomi/mimo-v2.5 | paid | terminal anchor |
| explorer | 1 | cmd | poolside/laguna-s-2.1-free | free | Terminal-Bench 70.2%, 118B/8B |
| explorer | 2 | or | nvidia/nemotron-3.5-lightning:free | free | |
| explorer | 3 | or | cohere/north-mini-code:free | free | 30B/3B agentic code |
| explorer | 4 | cmd | Qwen/Qwen3.7-Flash | paid | |
| explorer | 5 | nvidia | nvidia/nemotron-3.5-lightning-30b-a3b | free | second lane |
| explorer | 6 | cmd | deepseek/deepseek-v4-flash-fast | paid | terminal anchor |
| fixer | 1 | or | nex-agi/nex-n2.5-mini:free | free | self-verifying agentic |
| fixer | 2 | cmd | z-ai/glm-5.3-flash | paid | |
| fixer | 3 | cmd | deepseek/deepseek-v4-flash | paid | |
| fixer | 4 | cmd | deepseek/deepseek-v4.1-flash | paid | terminal anchor |
| observer | 1 | cmd | z-ai/glm-5.3-flash | paid | multimodal 320B/18B |
| observer | 2 | cmd | deepseek/deepseek-v4-flash-vision-exp | paid | vision |
| observer | 3 | zen | mimo-v2.5-free | free | DEAD — OpenCode CLI gate; watch slot |
| observer | 4 | or | thinkingmachines/inkling:free | free | multimodal 975B/41B; timed out in probes |
| static-best-free | 1 | zen | big-pickle | free | DEAD — CLI gate |
| static-best-free | 2 | zen | mimo-v2.5-free | free | DEAD |
| static-best-free | 3 | zen | ling-3.0-flash-fin-free | free | DEAD |
| static-best-free | 4 | zen | nemotron-3-ultra-free | free | DEAD |
| static-best-free | 5 | zen | nemotron-3.5-lightning-free | free | DEAD |
| static-best-free | 6 | zen | muse-spark-1.3-contributor-free | free | DEAD |
| static-best-free | 7 | zen | union-alpha | free | DEAD |
| static-best-free | 8 | cmd | meituan/LongCat-2.0:free | free | serving |
| static-best-free | 9 | cmd | poolside/laguna-s-2.1-free | free | serving |
| static-best-free | 10 | nvidia | nvidia/nemotron-3-super-120b-a12b | free | serving |
| static-best-free | 11 | nvidia | nvidia/nemotron-3-ultra-550b-a55b | free | serving |
| static-best-free | 12 | nvidia | deepseek-ai/deepseek-v4-pro-0813 | free | serving |
| static-best-free | 13 | nvidia | z-ai/glm-5.3 | free | serving |
| static-best-free | 14 | nvidia | moonshotai/kimi-k3 | free | serving |

Provider lanes: `cmd` = CommandCode, `nvidia` = NVIDIA NIM, `or` = OpenRouter (`:free` tier), `zen` = opencode-zen (paid API key). All `zen/*-free` entries return 403 FreeTierError upstream — never front-load them.

Bare ids (e.g. `mimo-v2.5-free`, `big-pickle`, `nemotron-3-super`) without a provider prefix are ambiguous and should never appear in chain definitions. The `opencode-zen-free` preset block in the OMOS jsonc and the old ADR-0001 reference these bare ids — both are superseded by the `omniroute/<role>` combo chains above and should be treated as stale.

## Client references (read-only context)

- omp: `omp/.omp/agent/models.yml` (9 combo ids declared) + `config.yml` `fallbackChains`/`modelRoles` → `omniroute/<role>`
- opencode/OMOS: `~/.config/opencode/opencode.json` `provider.omniroute.models` + `oh-my-opencode-slim.jsonc` `presets.balanced.<role>.model` → `omniroute/<role>`

## Removing the omniroute model list from opencode CLI

`opencode` shows every model the `opencode-models-discovery` plugin fetches from each openai-compatible provider's `/v1/models` endpoint — with omniroute that's ~1700 upstream ids flooding `opencode models` and the model picker. The `models` block in `opencode.json` only *adds* entries; it does not limit discovery.

To show only the 9 combo ids:

1. Trim the models block to just the combo ids used by omp/OMOS configs (see "Client references" above).
2. Disable discovery for the omniroute provider only:

```json
"omniroute": {
  "options": {
    "baseURL": "http://localhost:20128/v1",
    "modelsDiscovery": { "enabled": false }
  }
}
```

3. Verify: `opencode models omniroute` → exactly 9 rows; a real run still routes (`opencode run --model omniroute/orchestrator`).

Note: the plugin requires every declared model entry to be non-null — an id in `models` pointing at `null` fails config validation ("Expected object, got null provider.omniroute.models.X"). If adding a new combo id to opencode.json, give it a full entry (clone any sibling's shape).
