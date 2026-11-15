# ADR-0005: Order Chains by Role Capability, Not by Free Tier

## Status

Accepted 2026-11-14. Supersedes [ADR-0001](0001-balanced-preset-model-selection.md).

## Context

ADR-0001 ruled that every chain starts on a free Zen model and climbs to paid ones. It was written when `opencode-go` existed as a capped $10 subscription and when free-first looked free.

Three facts changed:

1. **The Go subscription is gone.** `opencode-go/*` models no longer exist, so ADR-0001's chains cannot be applied at all.
2. **Subscriptions are gifts.** Copilot Max and OpenAI arrive at zero cost to us, so their price no longer argues for avoiding them. CommandCode GOAT remains self-funded at $10 for $100 of credits.
3. **Free-first was measured, and it did not pay.** In a 65,774-step sample, subscription tiers carried only 18.7% of steps and the models actually burned were cheap ones (`claude-haiku-5.5`, `gpt-6-luna`). Frontier models in the tail almost never ran, because **a chain advances only on failure** — the head decides what runs, executing nearly every call.

That last point decides the design. Optimising a chain's tail optimises the part that does not run, while a weak head produces retries and churn on the part that does.

## Decision

**Order each chain by what the role needs, most capable first.**

- Judgment roles — orchestrator, oracle, council, skeptic, designer — lead with the model that yields the best result, accepting higher burn on the gift pools.
- Mechanical roles — explorer, observer, fixer — lead with a capable cheap model, because the work is bounded.
- One metered anchor ends each chain.

**Repetition follows the failure mode**, not a diversity rule:

- A spent allowance (`quota exceeded`, `usage limit reached`) excludes the failing provider for the rest of the descent, so a paid provider earns exactly one entry.
- Free-tier exhaustion (`Free usage exceeded`) is classified as permanent billing — it fails over immediately and excludes nothing — so free entries may repeat, including free Zen before a Zen anchor.

**Spend doctrine differs per pool.** Copilot and OpenAI buy quality: use the model that best fits the role and accept fast burn when the role justifies it. CommandCode buys reach: prefer boosted models (GLM-5.3 Flash, DeepSeek V4.1 Flash carry $100 each) over $10-allowance premium models.

## Alternatives Considered

- **Keep free-first (ADR-0001, updated for current models).** Rejected: the measurement shows the head decides what runs, so free-first puts the weakest model in the only position that reliably executes.
- **Order by price, cheapest first.** Rejected: a cheap model that fails and retries costs more than a capable one that succeeds once.
- **Maximise provider diversity per hop.** Rejected: the chain is failure-driven, not capability-driven, so a repeated free entry buys a retry while a repeated paid provider buys nothing.

## Consequences

### Positive

- The model that runs is chosen for the job, so churn from weak heads drops.
- Gift pools are actually consumed rather than idling behind a free head.
- One consistent rule — the head decides what runs — replaces a per-role free/paid split.

### Negative

- Monthly burn on Copilot and OpenAI rises substantially; five judgment roles now open on the OpenAI Plus pool.
- Chains concentrated on OpenAI Plus risk the 5-hour window, which showed only 16% remaining at design time.
- Mechanical roles still lead free, so they retain the weak-head behaviour deliberately.

### Risks

- Copilot's pool was exhausted at design time (resets 1 December). Judgment chains therefore start on OpenAI, and their first failure lands on the next provider, not Copilot.
- The "head decides what runs" premise assumes software failures dominate. If provider rate limits fire often, tails get more exercise and the balance shifts back toward cheap heads.
- No live failover was exercised; the ordering rests on the fallback implementation's documented semantics, not observed quota errors.

## References

- Chain rules: [`omp/ROUTING-CHAIN-RULES.md`](../../omp/ROUTING-CHAIN-RULES.md)
- Fallback semantics: `oh-my-opencode-slim/src/hooks/foreground-fallback/index.ts`
- Usage evidence: `opencode api experimental.session.stats`
