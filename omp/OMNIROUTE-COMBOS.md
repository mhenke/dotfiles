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

Framework for model hierarchies in agent chains — reliability + cost efficiency. Subscription lanes (`opencode-go/`, `cline-pass/`, `commandcode/`) go early, never last — need a paygo fallback (`opencode/`, unmetered) or the system fails under load. Free/unmetered models absorb basic load before paid ones. Council/skeptic blocks mirror their agent lists.

### Rules

Applies to balanced preset agents, council balanced presets α/β/γ, `agents.council`, `agents.skeptic`.

1. No more than one subscription model (`opencode-go/...` or `cline-pass/...`) per chain. One outage kills both — a second sub model won't help. (Primary can be sub; fallbacks must not be sub.)
2. Sub entry must not be in the last slot. Must fire before hitting paygo, or you're not using what you pay for.
3. Last entry must be an unmetered `opencode/` paygo model. Not `nvidia/`, not `opencode-go/`, not `cline-pass/`. Guarantees a stable, unmetered final fallback.
4. Multiple non-sub `opencode/` entries allowed only if a free model (or `opencode/big-pickle`) precedes any paid one. Free tier absorbs basic tasks first; paid tokens saved for hard fallbacks.
5. Zero `nvidia/` models in a strict balanced preset — all slots filled by RoleZen paygo `opencode/` (`minimax-m2.7`, `qwen3.7-plus`, `deepseek-v4-flash`, `qwen3.5-plus`).
   *Exception [v7]:* if shielding sub budget under high concurrency is the priority, free NVIDIA NIM previews may sit at the very front as a zero-cost cushion before the sub layer.
6. Council/agent blocks mirror the balanced preset exactly: `agents.council` → orchestrator list. `agents.skeptic` → oracle list. `council.presets.balanced.alpha` → oracle list.

### Definitions / scope

1. "Free" = `opencode/...-free` models + `opencode/big-pickle`. Active lineup (per Zen site, 2026-09-17): `big-pickle`, `union-alpha`, `mimo-v2.5-free`, `ling-3.0-flash-fin-free`, `nemotron-3-ultra-free`, `nemotron-3.5-lightning-free`, `muse-spark-1.3-contributor-free`. (1.2 contributor is superseded by 1.3; the stray `deepseek-v4-flash-free` id still exists in the omniroute catalog but is off the Zen site list. `union-alpha` uses Anthropic-style `/v1/messages`, muse-spark-1.3 uses OpenAI `/v1/responses` upstream — the only two non-chat-completions endpoints on Zen free tier. `opencode-zen/muse-spark-1.3-contributor-free` returned 500 on probes 2026-09-17 — upstream issue, kept but watch it.)
2. "Chain" = model + `fallback_models`, in order.
3. Rules exclude `nvidia-free` and `opencode-zen-free` presets — intentionally single-provider playgrounds.

### Resource dynamics

1. Sub quota is one shared dollar pool ($60/mo Go, $70/mo GOAT), not per-model. Per-model "allowances" are sub-caps within that pool. Shift high-concurrency load to free cushions to avoid early pool depletion.
2. Model diversity in a chain buys only transient fault tolerance (rate limits, timeouts) — no compounding cognitive benefit on single-turn calls. Keep chains short; excess nesting adds latency and risks orphaned subagent recoveries the parent orchestrator already timed out on.

### OmniRoute layering (how these rules map to omniroute combos)

Free cushions from **all** providers sit front (zen → cmd → openrouter), then the NVIDIA NIM layer, then paid CommandCode terminal anchors. Duplicate models across providers are intentional — same model via a second lane = transient-fault tolerance, not redundancy to prune. Overlap (e.g. nemotron-3-ultra on zen AND openrouter) is a feature: free is free.

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

- **OpenCode Zen free tier is OAuth/CLI-bound — dead lane from omniroute.** Probed 2026-09-17 with omniroute's `apikey` connection: `mimo-v2.5-free`/`nemotron-3-ultra-free`/`ling-3.0-flash-fin-free` → `403 "OpenCode's free tier can only be used from within OpenCode"`; `union-alpha` → `402 needs API key` (paid-only via key); `muse-spark-1.3-contributor-free` → `500` (upstream is OpenAI `/v1/responses`, not chat-completions — omniroute's proxy can't reach it); `big-pickle` → timeout. **Paid zen ids work fine via the same key** (`opencode-zen/glm-5.3-flash` → 200). Zen free models only serve inside the OpenCode CLI, which is OAuth'd (`~/.local/share/opencode/auth.json`). Consequence: do NOT put zen `*-free` ids at the front of omniroute combos — every request eats a 403 hop. Keep them out entirely, or at most one slot late in a chain if you want automatic coverage when the gate lifts.
- **CommandCode free tier works from omniroute**: `cmd/meituan/LongCat-2.0:free`, `cmd/inclusionai/ling-3.0-flash-sante:free` → 200; `cmd/poolside/laguna-s-2.1-free` → 429 under load but alive.
- **No new combo id? Nothing to refresh downstream.** omp (`models.yml`) and opencode (`opencode.json`) declare combo ids statically; chain *contents* resolve at request time. Only if you create/rename a combo id do clients need updating (`omniroute setup-opencode` regenerates the opencode provider block; add the id to `omp/.omp/agent/models.yml` by hand).

## Combo inventory (2026-09-17, zen-free-lanes-cleansed)

| combo | n | chain |
|---|---|---|
| skeptic | 3 | or/nemotron-3-ultra:free → cmd/Qwen3.7-Plus → zen/opencode/qwen3.7-plus (paid) |
| orchestrator | 7 | cmd/LongCat-2.0:free → or/nemotron-3-super:free → nv/nemotron-3-super → nv/nemotron-3.5-lightning → cmd/Qwen3.8-Flash → cmd/deepseek-v4-flash → cmd/deepseek-v4.1-flash |
| oracle | 5 | or/nemotron-3-ultra:free → nv/kimi-k3 → nv/deepseek-v4-pro-0813 → cmd/muse-spark-1.3-contributor → cmd/mimo-v2.5-pro |
| designer | 5 | or/inkling-small:free → cmd/glm-5.3-flash → cmd/muse-spark-1.3-contributor → nv/kimi-k3 → cmd/deepseek-v4-flash-vision-exp |
| librarian | 5 | cmd/ling-3.0-flash-sante:free → or/ling-3.0-flash-fin:free → or/dots-3-note-preview:free → cmd/Qwen3.7-Flash → cmd/mimo-v2.5 |
| explorer | 6 | cmd/laguna-s-2.1-free → or/nemotron-3.5-lightning:free → or/north-mini-code:free → cmd/Qwen3.7-Flash → nv/nemotron-3.5-lightning → cmd/deepseek-v4-flash-fast |
| fixer | 4 | or/nex-n2.5-mini:free → cmd/glm-5.3-flash → cmd/deepseek-v4-flash → cmd/deepseek-v4.1-flash |
| observer | 4 | cmd/glm-5.3-flash → cmd/deepseek-v4-flash-vision-exp → zen/mimo-v2.5-free (gate-lift watch slot) → or/inkling:free |
| static-best-free | 14 | zen big-pickle + mimo-free + ling-fin-free + nemotron-ultra-free + lightning-free + muse-1.3-free + union-alpha → cmd/LongCat-2.0:free → cmd/laguna-s-2.1-free → nv ×5 |

Prefix key: `zen/` = opencode-zen, `cmd/` = CommandCode, `or/` = openrouter `:free`, `nv/` = nvidia NIM.

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
