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

Example body (`/tmp/omniroute-combos/fixer.json`):

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

## Chain-structure protocol (Balanced Preset)

1. **Free cushioning first** — zero-cost models absorb baseline load.
2. **Mid-layer efficiency** — cheap/high-benchmark models do the primary work.
3. **Paygo terminal fallback** — chain ends on a reliable paid model.

## Known gotchas (2026-09-17)

- **`oc/*` ids are dead.** The `oc` provider vanished from the catalog; its combo entries 401. Use `opencode-zen/*` equivalents.
- **OpenCode Zen free tier is gated outside OpenCode.** Direct calls return `403 "OpenCode's free tier can only be used from within OpenCode"` (Console-auth path) or `402 "requires an opencode API key"`. As omniroute chain members they always fall through — harmless but not serving. Fix: add an OpenCode API key in OmniRoute Settings → Providers → opencode-zen.
- **CommandCode free tier works from omniroute**: `cmd/meituan/LongCat-2.0:free`, `cmd/inclusionai/ling-3.0-flash-sante:free` → 200; `cmd/poolside/laguna-s-2.1-free` → 429 under load but alive.
- **No new combo id? Nothing to refresh downstream.** omp (`models.yml`) and opencode (`opencode.json`) declare combo ids statically; chain *contents* resolve at request time. Only if you create/rename a combo id do clients need updating (`omniroute setup-opencode` regenerates the opencode provider block; add the id to `omp/.omp/agent/models.yml` by hand).

## Client references (read-only context)

- omp: `omp/.omp/agent/models.yml` (9 combo ids declared) + `config.yml` `fallbackChains`/`modelRoles` → `omniroute/<role>`
- opencode/OMOS: `~/.config/opencode/opencode.json` `provider.omniroute.models` + `oh-my-opencode-slim.jsonc` `presets.balanced.<role>.model` → `omniroute/<role>`

## Combo inventory (2026-09-17)

| combo | strategy | chain |
|---|---|---|
| orchestrator | priority | opencode-zen/mimo-v2.5-free → cmd/LongCat-2.0:free → cmd/Qwen3.8-Flash → cmd/deepseek-v4.1-flash |
| oracle | priority | opencode-zen/big-pickle → opencode-zen/nemotron-3-ultra-free → cmd/muse-spark-1.3-contributor → cmd/mimo-v2.5-pro |
| designer | priority | opencode-zen/mimo-v2.5-free → cmd/glm-5.3-flash → cmd/muse-spark-1.3-contributor → cmd/deepseek-v4-flash-vision-exp |
| librarian | priority | opencode-zen/ling-3.0-flash-fin-free → cmd/ling-3.0-flash-sante:free → cmd/Qwen3.7-Flash → cmd/mimo-v2.5 |
| explorer | priority | cmd/laguna-s-2.1-free → opencode-zen/union-alpha → cmd/Qwen3.7-Flash → cmd/deepseek-v4-flash-fast |
| fixer | priority | opencode-zen/nemotron-3.5-lightning-free → cmd/glm-5.3-flash → cmd/deepseek-v4-flash → cmd/deepseek-v4.1-flash |
| observer | priority | cmd/glm-5.3-flash → cmd/deepseek-v4-flash-vision-exp → opencode-zen/mimo-v2.5-free |
| skeptic | priority | opencode-zen/muse-spark-1.2-contributor-free → opencode-zen/nemotron-3-ultra-free → cmd/Qwen3.7-Plus → opencode-zen/opencode/qwen3.7-plus |

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
