# ADR-0001: Balanced Preset Model Selection for oh-my-opencode-slim

## Status

Accepted

## Context

oh-my-opencode-slim provides failover redundancy across a multi-agent orchestration team. When
primary LLM providers experience disruptions, each agent falls back through a model chain. The
`balanced` preset must strategically allocate models across roles to:

- **Maximize Go subscription value** ($10/mo for ~$70/mo equivalent, with hard caps: $12/5h,
  $30/week, $60/mo equivalent)
- **Minimize Zen/direct balance burn** for pay-per-use providers
- **Preserve vision capability** in roles that handle images/screenshots
- **Match model throughput to role frequency** (e.g., orchestrator fires every turn; oracle rarely)
- **Exit the subscription pool immediately** on provider failure (don't stack same-provider fallbacks)

Three providers are available:

| Provider | Billing | Characteristics |
|---|---|---|
| `opencode-go/` | Subscription (capped) | Flat $10/mo; hard request ceilings per model per 5h window |
| `opencode/` (Zen) | Usage balance | Pay-per-use from Zen credit balance; includes free-tier models |
| `deepseek/` | Direct | Pay-per-use; ~4× cheaper than Zen-hosted DeepSeek via arbitrage |

### Key Model Economics

| Model | Zen Price (input/M) | Go Limit (req/5h) | Vision |
|---|---|---|---|
| `mimo-v2.5-free` | Free | N/A (Zen only) | Yes |
| `mimo-v2.5` | Not available on Zen | 30,100 | Yes |
| `mimo-v2.5-pro` | Not available on Zen | 3,250 | Yes |
| `qwen3.6-plus` | $0.50 | 3,300 | Yes |
| `qwen3.7-plus` | N/A | 4,300 | Yes |
| `qwen3.7-max` | N/A | 950 | Yes |
| `minimax-m3` | Not available on Zen | 3,200 | Yes |
| `minimax-m2.7` | $0.30 | 3,400 | **No** |
| `kimi-k2.6` | $0.95 | 1,150 | Yes |
| `kimi-k2.7-code` | Not available on Zen | 1,350 | Yes |
| `deepseek-v4-flash` | Free (Zen), $0.14 (direct) | 31,650 | No |
| `deepseek-v4-pro` | $1.74 (Zen), $0.435 (direct) | 3,450 | No |

## Decision Drivers

1. **Orchestrator throughput.** Orchestrator delegates on every turn. GLM-5.1's 880 req/5h
   ceiling was exhausting Go bandwidth. The chain must start free, then use high-throughput Go,
   then fall to a capable paid model.
2. **Vision verification.** Observer, designer, and their fallbacks must handle images.
   Confirmed via research: MiniMax M3 (vision), Kimi K2.6/K2.7 (vision via MoonViT), Qwen3.6+
   (multimodal), MiMo-V2.5 (vision). MiniMax M2.7 is text-only and excluded from vision paths.
3. **MiniMax M3 vs Kimi K2.6 economics.** At near-identical SWE-Bench Pro scores (59.0% vs
   58.6%), MiniMax M3 costs ~1/8th the Zen balance per request. MiniMax is the "employee" for
   execution; Kimi is the "judge" for validation.
4. **Provider exit strategy.** If `opencode-go/` throttles, fallback to `opencode/` (Zen) or
   `deepseek/` — never chain multiple Go models in a single fallback sequence.

## Decision

### Per-Agent Model Chains (balanced preset)

| Role | Primary | Fallback 1 | Fallback 2 | Rationale |
|---|---|---|---|---|
| orchestrator | `opencode/mimo-v2.5-free` | `opencode-go/mimo-v2.5` | `deepseek/deepseek-v4-pro` | Free Zen first (no cost); Go extracts subscription value at 30K req/5h; deepseek-pro direct arbitrage as capable last resort |
| oracle | `opencode-go/kimi-k2.7-code` (max) | `opencode/kimi-k2.6` | `deepseek/deepseek-v4-pro` | Infrequent deep reasoning; Go buys real capability uplift over free tier; deepseek-pro for reasoning-heavy bailout |
| designer | `opencode-go/kimi-k2.7-code` (medium) | `opencode/qwen3.6-plus` | `opencode/kimi-k2.6` | Go-tier model for structural accuracy; Zen fallbacks for UI/UX quality |
| librarian | `opencode/mimo-v2.5-free` | `opencode-go/mimo-v2.5` | `deepseek/deepseek-v4-pro` | Free → paid equivalent → cheapest capable ($0.435 vs $0.50 for qwen) |
| explorer | `opencode/deepseek-v4-flash-free` | `opencode-go/deepseek-v4-flash` | `deepseek/deepseek-v4-flash` | Free → paid equivalent → cheapest capable (same model, direct arbitrage) |
| fixer | `opencode/deepseek-v4-flash-free` (high) | `opencode-go/deepseek-v4-flash` | `deepseek/deepseek-v4-flash` | Same as explorer — free → paid equiv → cheapest |
| observer | `opencode/mimo-v2.5-free` (low) | `opencode-go/mimo-v2.5` | `opencode/qwen3.6-plus` | Free → paid equivalent → cheapest vision-capable (deepseek lacks vision) |

### Council (balanced preset)

| Councillor | Primary | Fallback 1 | Fallback 2 |
|---|---|---|---|
| alpha | `opencode-go/kimi-k2.7-code` (high) | `opencode/kimi-k2.6` | `deepseek/deepseek-v4-pro` |
| beta | `opencode-go/minimax-m3` (medium) | `opencode/qwen3.6-plus` | `deepseek/deepseek-v4-pro` |
| gamma | `opencode/mimo-v2.5-free` | `opencode-go/mimo-v2.5` | `opencode/qwen3.6-plus` | Free → paid equivalent → cheapest vision-capable; council's vision councillor |

**Execution mode:** parallel

### Standalone Agents

| Agent | Primary | Fallback 1 | Fallback 2 |
|---|---|---|---|
| council (aggregator) | `opencode/mimo-v2.5-free` | `opencode-go/mimo-v2.5` | `deepseek/deepseek-v4-pro` |

Note: `agents.councillor` removed — redundant since `council.presets` override it.

### Fallback Chain Rules

1. **Free → paid equivalent.** When a free Zen model is the primary, the first
   fallback MUST be its paid equivalent (same model family on Go, since Zen only
   offers free versions of these models). For example: `opencode/mimo-v2.5-free`
   → `opencode-go/mimo-v2.5`, `opencode/deepseek-v4-flash-free` →
   `opencode-go/deepseek-v4-flash`.

2. **No Go→Go.** Never chain two `opencode-go/` models together. A Go model
   failure means the provider is down; another Go model won't help.

3. **Cheapest capable model last.** The final fallback should be the cheapest
   model that meets the role's requirements (vision, reasoning, etc.). For
   text-only roles, direct `deepseek/deepseek-v4-pro` ($0.435/M) beats Zen
   `opencode/qwen3.6-plus` ($0.50/M). For vision roles, the cheapest
   vision-capable option is `opencode/qwen3.6-plus`.

4. **Council must have at least one fully vision-capable councillor.** Alpha
   (`kimi-k2.7-code` → `kimi-k2.6`) and beta (`minimax-m3` → `qwen3.6-plus`)
   have vision through primary+fallback1. Gamma is fully vision-capable across
   all three hops (`mimo-v2.5-free` → `mimo-v2.5` → `qwen3.6-plus`). Together,
   `@council` can handle screenshots, diagrams, and visual design reviews.

### Alternatives Considered

#### Qwen3.6-Plus for Orchestrator

Qwen3.6-Plus was evaluated as an orchestrator candidate:

| Metric | Qwen3.6-Plus | MiMo-V2.5 (chosen) | Winner |
|---|---|---|---|
| Zen price (input/M) | $0.50 | Free (`mimo-v2.5-free`) | MiMo |
| Go limit (req/5h) | 3,300 | 30,100 | MiMo (9.1×) |
| Vision | Yes | Yes | Tie |
| General capability | Strong coordinator | Capable enough | Qwen |

**Verdict:** Qwen3.6-Plus is a stronger model on paper, but orchestrator is pure coordination
and delegation — it doesn't need deep reasoning. MiMo-V2.5-free costs $0 on Zen, and MiMo-V2.5
on Go provides 9× more throughput for extracting subscription value. Qwen3.6-Plus remains as a
fallback in designer, librarian, and council chains where its capability is better leveraged.

#### Qwen3.6-Plus vs DeepSeek-V4-Pro as Final Fallback

For orchestrator's last-resort hop:

| Metric | DeepSeek-V4-Pro (direct) | Qwen3.6-Plus (Zen) |
|---|---|---|
| Price (input/M) | $0.435 | $0.50 |
| Go available | 3,450 req/5h | 3,300 req/5h |
| Provider diversity | Direct (separate from Zen/Go) | Same Zen pool |

**Verdict:** DeepSeek-V4-Pro via direct arbitrage is cheaper ($0.435 vs $0.50/M) and provides
provider diversity — if both Zen and Go are degraded, the direct DeepSeek endpoint is a separate
service that's less likely to be simultaneously affected.

## Consequences

### Positive

- Orchestrator starts free on Zen, falls back to Go with 30,100 req/5h headroom, then
  deepseek-pro direct — provider-diverse, cost-ordered chain
- GLM-5.1 bandwidth bottleneck eliminated (was burning Go quota at 880 req/5h)
- Go subscription value extracted on high-frequency roles (orchestrator) and capability-dependent
  roles (oracle, designer) without wasting capped quota on free-tier-eligible work
- Observer routine status reporting runs on free tier; Go only burned on escalated manual
  visual analysis
- All vision-capable chains verified end-to-end; text-only MiniMax M2.7 excluded from observer path
- All free Zen primaries now fall back to their Go paid equivalents first (MiMo-V2.5 for
  mimo-v2.5-free; DeepSeek-V4-Flash for deepseek-v4-flash-free), ensuring consistency and
  extracting Go subscription value

### Negative

- `agents.councillor` removed — redundant since `council.presets` override it. Only `agents.council`
  remains as the Council synthesizer.
- MiMo-V2.5-free as orchestrator primary may produce worse delegation decisions than GLM-5.1;
  treat as reversible if observed

### Risks

- If observer fires far less often than expected, the free-tier-first strategy yields no
  meaningful savings; the swap costs nothing either way
- Kimi K2.7-Code vision API path (OpenCode Go provider) may differ from Kimi Code CLI; test
  with a real image before depending on it
- `mimo-v2.5-free` is a limited-time free model on Zen; if deprecated, switch orchestrator
  primary to another free-tier model or `opencode-go/mimo-v2.5` with deepseek fallback

## References

- [oh-my-opencode-slim upstream](https://github.com/alvinunreal/oh-my-opencode-slim)
- [OpenCode Go pricing and model limits](https://opencode.ai/go)
- [OpenCode Zen pricing](https://opencode.ai/docs/zen/)
- MiniMax M3 vs Kimi K2.6 cost analysis: ~8× more requests per Zen balance for near-identical
  SWE-Bench Pro scores (59.0% vs 58.6%)
