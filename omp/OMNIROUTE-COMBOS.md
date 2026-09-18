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
3. **Last entry must be a paid paygo/subscription anchor: `deepseek/deepseek-*` (DeepSeek platform), `opencode-zen/` non-free, or `cmd/deepseek-*` (DeepSeek subscription).** Not `nv/`, not `opencode-go/`, not `cline-pass/`, not free. Guarantees a stable, reliable final fallback. **Diversify across providers fleet-wide — do not put every chain's anchor on one lane** (2026-09-18: qwen account-gating on Zen briefly stranded all 8 zen anchors; the 4/4 platform↔zen split is the standing layout).
4. **Free models front, paid models back.** Free tier (any provider) absorbs basic load first; paid tiers saved for hard fallbacks. Multiple `cmd/` free entries allowed as long as they precede any paid one. **Rationale:** free models are unreliable (rate limits, downtime, changing terms, stealth-model identity drift) — front-loading them is a cost-saving measure, not a reliability play. Paid tiers (DeepSeek, opencode-zen) have provider SLAs and are the anchors.
5. **`nvidia/` models are all free (NVIDIA NIM previews).** They belong in the front free-cushion slot. Zero paid `nvidia/` models exist in the fleet.
6. **Council/agent blocks mirror the balanced preset exactly:** `agents.council` → orchestrator list. `agents.skeptic` → oracle list. `council.presets.balanced.alpha` → oracle list.

### Definitions / scope

1. "Free" (routing-eligible) = any `*:free` model on `cmd/`/`or/` + nvidia NIM previews, all serving-verified. **Zen `*-free` ids are NOT routing-eligible** — the six (big-pickle, mimo-v2.5-free, ling-3.0-flash-fin-free, nemotron-3-ultra-free, nemotron-3.5-lightning-free, muse-spark-1.3-contributor-free) are blocked by the OpenCode CLI gate + per-model account gating (`union-alpha` and the `opencode/qwen3.7-plus` nested anchor are additionally absent from Zen's live catalog). They stay registered on the zen connection for easy re-add but were pruned from every chain 2026-09-18 (v6) — each failed a real request 8× today, so a watch slot only guarantees a wasted hop. Probes are the authority on eligibility, not the catalog.
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

## Known gotchas (2026-09-18)

- **DeepSeek platform rename (2026-09-18): `deepseek-flash` is canonical (model version DeepSeek-V4.1-Flash).** Legacy platform ids `deepseek/deepseek-v4-flash` and `deepseek/deepseek-v4-flash-vision-exp` are retired — requests alias to V4.1-Flash where still accepted, but `deepseek/deepseek-v4-flash` already 400s via omniroute (not in active catalog). **Scope: DeepSeek platform lane only** — `cmd/deepseek/*`, `opencode-zen/deepseek-*`, `nvidia/deepseek-ai/*` ids unchanged. Platform specs: 1M ctx, 384K max out, thinking + non-thinking modes, vision ✓ on flash (pro has no vision), Responses + Anthropic APIs ✓. Pro keeps `deepseek-v4-pro` (DeepSeek-V4-Pro-0813). omos `opencode.json` build agent updated to `deepseek/deepseek-flash`; plan agent stays `deepseek/deepseek-v4-pro`.
- **OpenCode free models are gate-locked to the OpenCode CLI at the SERVER — confirmed at source 2026-09-17.** OmniRoute ships TWO OpenCode lanes: `opencode` (`oc`, no-auth public endpoint) and `opencode-zen` (API key). BOTH now 403 on free models with `FreeTierError "OpenCode's free tier can only be used from within OpenCode"` — tested with a valid Zen key, with no key (no-auth lane), and with CLI headers replicated (`x-opencode-client/session/request/project`, UA). The gate is evaluated server-side per request; only the OpenCode CLI's own session binding passes it. Consequence: `oc/*` and `zen *-free` ids are dead weight in omniroute combos — do NOT front-load them; keep `oc` in blockedProviders. Custom model entries for the free ids are already registered on the zen connection, so if the gate ever lifts they light up with no reconfig.
- **Zen paid lane + omniroute gotcha:** omniroute's zen connection needs the FULL Zen key. A truncated/partial key silently yields `402 "requires an opencode API key"` at request time while `test-connection` still reports what looks like success. If zen suddenly 402s in omniroute: (1) GET `/api/providers/client`, compare stored `apiKey` length against the real key in `~/.local/share/opencode/auth.json` (`opencode.key`), (2) PATCH `/api/providers/<conn-id>` with the full key, (3) POST `/api/providers/<conn-id>/test` until `testStatus: active`. 2026-09-17: fixed exactly this — omniroute had a stale 20-char key; restored a full 67-char key and paid zen models (e.g. `opencode-zen/glm-5.3-flash`, `opencode-zen/qwen3.6-plus`) returned to 200. **A freshly minted Zen key was tested the same day: paid 200, free models still `403 FreeTierError` — the free-tier CLI-only gate applies to every API key, new or old.**
- **Zen qwen models are ACCOUNT-gated (2026-09-18).** On this workspace's key, every `*-qwen*` id (qwen3.5-plus, qwen3.6-plus, nested `opencode/qwen3.7-plus`) returns `402 requires an opencode API key` / `401 Model opencode/qwen3.7-plus is not supported` — while `glm-5.2/5.3-flash` and `deepseek-v4-flash/vision-exp` serve 200 **on the same key in the same second**. Distinguishing from the truncation gotcha above: truncated key = testStatus `expired` + ALL paid models 402; account gating = testStatus `active` + only the gated family 402. Zen admin panel "Model access" (per-workspace enable/disable) is the lever; we did not enable qwen there. Do NOT use qwen ids as anchors. Also: 2026-09-18 a PATCH with `auth.json`'s `opencode.key` turned out to be a DIFFERENT key than the one installed in omniroute (both 67 chars, different prefixes) — check the key actually matches before "restoring" it, and always re-probe a known-good paid model afterwards.
- **NVIDIA NIM added Z.ai free endpoints (2026-09-16)**: `nvidia/z-ai/glm-5.3` (753B text MoE, sparse attention, reasoning+tools) and `nvidia/z-ai/glm-5.3-flash` (320B/18B-active multimodal). Probed 2026-09-17: glm-5.3 → 200; glm-5.3-flash → 000/504 (endpoint live in catalog but unstable via omniroute — retry before trusting).
- **`nvidia/deepseek-ai/deepseek-v4-flash-0731` deprecated upstream** (per NVIDIA, removal pending). Removed from static-best-free 2026-09-17, replaced by `nvidia/z-ai/glm-5.3`. (deepseek-v4-pro-0813 still live, kept.)
- **CommandCode free tier works from omniroute**: `cmd/meituan/LongCat-2.0:free`, `cmd/inclusionai/ling-3.0-flash-sante:free` → 200; `cmd/poolside/laguna-s-2.1-free` → 429 under load but alive.
- **UI combo "Test" false-negatives on reasoning models (2026-09-18).** The test panel's tiny token budget (~10 out-tokens) is consumed entirely by reasoning tokens; providers return 200 but the combo quality gate rejects with `reasoning consumed N/N tokens — no content output` and the slot shows "error" in ~ms. Reproduced: `max_tokens=10` → `finish=length`, empty content; `max_tokens=200` → clean reply. Verify combos via API smoke probes (`POST /v1/chat/completions` with `model=<combo>`, realistic max_tokens) and `~/.omniroute/call_logs/` + `combo trace terminal=` lines in `logs/application/app.log` — not via the UI Test button.
- **No new combo id? Nothing to refresh downstream.** omp (`models.yml`) and opencode (`opencode.json`) declare combo ids statically; chain *contents* resolve at request time. Only if you create/rename a combo id do clients need updating (`omniroute setup-opencode` regenerates the opencode provider block; add the id to `omp/.omp/agent/models.yml` by hand).

## Combo inventory (2026-09-18, v6 — dead mid-chain lanes pruned)

All eight chains now contain only **live-probed serving** entries — every 403/500 Zen-free watch slot and the flaky `inkling` OpenRouter entries were removed. Chains are shorter (no failed-hop waste), every slot from first to last returns 200 today. The six Zen `*-free` models and the OpenCode no-auth `oc` lane stay **registered on the connections** (addressable, so a future gate-lift needs only a re-add), but they are no longer in the routing chains — a watch-slot that fails every real request just burns latency and a retry.

**Two independent reasons a Zen free id fails (both confirmed live 2026-09-18, corrected from an earlier wrong diagnosis):**
1. The **OpenCode CLI gate** — free tier only serves from inside the OpenCode CLI (`403 FreeTierError`), hits both the `oc` no-auth lane and the API-key lane's `*-free` ids.
2. **Per-model account gating** — on this workspace the `*-free` ids ALSO return `402/403 per-model access` independent of the CLI gate. A model can be blocked by either, both, or the id may be absent from Zen's live catalog (`400`) — the case for the old `opencode/qwen3.7-plus` anchor, which was dead three ways over.

Working paid anchors (probed 200, correct 67-char `sk-An2xL…` key on connection `0825b07d`, `test_status: active`): `deepseek/deepseek-flash` (platform, V4.1-Flash), `opencode-zen/glm-5.3-flash`, `opencode-zen/deepseek-v4-flash`, `opencode-zen/deepseek-v4-flash-vision-exp`, `opencode-zen/glm-5.2`. NOTE: `auth.json`'s `opencode.key` (`sk-fg6g9…`) is a DIFFERENT key from the one omniroute stores (`sk-An2xL…`) — do NOT "restore" from auth.json; the stored key is the working one.

| combo | n | chain (all slots serving-verified) |
|---|---|---|
| skeptic | 4 | or/nemotron-3-ultra:free → nv/kimi-k3 → cmd/Qwen3.7-Plus → **zen/glm-5.3-flash** |
| orchestrator | 6 | cmd/LongCat-2.0:free → or/nemotron-3-super:free → nv/nemotron-3-super → nv/nemotron-3.5-lightning → cmd/Qwen3.8-Flash → **deepseek/deepseek-flash** |
| oracle | 4 | or/nemotron-3-ultra:free → nv/kimi-k3 → cmd/muse-spark-1.3-contributor → **zen/glm-5.3-flash** |
| designer | 4 | nv/kimi-k3 → cmd/glm-5.3-flash → cmd/deepseek-v4-flash-vision-exp → **deepseek/deepseek-flash** |
| librarian | 5 | cmd/ling-3.0-flash-sante:free → or/ling-3.0-flash-fin:free → or/dots-3-note-preview:free → cmd/mimo-v2.5 → **deepseek/deepseek-flash** |
| explorer | 5 | cmd/laguna-s-2.1-free → or/nemotron-3.5-lightning:free → or/north-mini-code:free → cmd/deepseek-v4-flash-fast → **zen/deepseek-v4-flash** |
| observer | 3 | cmd/glm-5.3-flash → cmd/deepseek-v4-flash-vision-exp → **zen/deepseek-v4-flash-vision-exp** |
| fixer | 4 | or/nex-n2.5-mini:free → cmd/laguna-s-2.1-free → cmd/Qwen3.7-Flash → **deepseek/deepseek-flash** |
| static-best-free | 6 | cmd/LongCat-2.0:free → cmd/laguna-s-2.1-free → nv: nemotron-3-super, nemotron-3-ultra, z-ai/glm-5.3, kimi-k3 |

Anchor split (rule 3): platform `deepseek/deepseek-flash` ×5 (orchestrator/designer/librarian/fixer + …) vs Zen paygo ×3 (skeptic/oracle→glm-5.3-flash, explorer/observer→zen deepseek). Vision roles keep a vision anchor: designer=platform V4.1-Flash (vision ✓), observer=zen v4-flash-vision-exp. Provider lanes: `deepseek/`=platform, `cmd/`=CommandCode sub, `or/`=OpenRouter free, `nv/`=NVIDIA NIM free, `zen/`=opencode-zen paygo.

**Known-flaky but kept (rate/availability, not dead — they serve 200 and belong):** `nv/kimi-k3` (3× 504 today, OmniRoute local rate-limit, not upstream), `cmd/laguna-s-2.1-free` (429 under load), `cmd/muse-spark-1.3-contributor` (4× 502 empty-response), `or/inkling` variants REMOVED (9× 403 agentic-harness-gate — not flaky, policy-blocked for omniroute).

**Key changes v5 → v6 (2026-09-18, dead-slot prune):**
- Removed all 8 in-chain Zen `*-free` watch slots (6 models, all 403/500 every request today) across skeptic/orchestrator/oracle/designer/librarian/explorer/observer/fixer + all 6 from static-best-free (12→6). Rationale: a watch slot that fails 100% adds a guaranteed failed hop + latency on every request; re-addable in one PUT when a gate lifts.
- Removed `or/inkling-small:free` (designer) + `or/inkling:free` (observer) — `403 only available on agentic harnesses` is an OpenRouter policy block, not transient.
- Chain lengths: skeptic 6→4, orchestrator 8→6, oracle 7→4, designer 6→4, librarian 6→5, explorer 6→5, observer 4→3, fixer 6→4, static-best-free 12→6. Verified: 8/8 combos smoke-test serving from the free front; read-back clean.

**Key changes v4 → v5 (2026-09-18, provider diversification):** split anchors 4/4 platform↔Zen so one lane's policy can't strand every chain; `deepseek/deepseek-flash`=V4.1-Flash (TB 2.1 90.6, vision, cache-hit $0.003/M).
**Key changes v3 → v4 (2026-09-18, spend alignment):** dead qwen anchors → cheapest serving per role; oracle glm-5.2 cut 10× to glm-5.3-flash; pruned dead `nv/deepseek-v4-pro-0813`.

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
