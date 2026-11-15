# ADR-0006: Size the Monthly Budget, Then Assign Heads by Call Volume

## Status

Accepted 2026-11-15. Amends [ADR-0005](0005-chain-order-by-capability.md), whose spend doctrine it replaces.

## Context

ADR-0005 ordered chains by role capability and split the pools by intent: Copilot and OpenAI "buy quality" and should be spent freely, CommandCode "buys reach" and should be stretched. That split assumed the pools were interchangeable, differing only in how much we cared about the price.

Four measurements taken 2026-11-15 show the pools are not interchangeable, and that ADR-0005's doctrine misallocated them.

1. **Call volume is extremely uneven.** Over 148,484 assistant messages, orchestrator alone is 43.3%, `build` 16.6%, fixer 12.8%; oracle 5.8%, explorer 5.6%, designer 4.4%, skeptic 2.0%, council 1.2%. Since the head runs nearly every call, the head assignment *is* the allocation.

2. **OpenAI is metered in messages and burns fast.** Sampled every hour: 6% → 37% → 64% → 84% → 91% of the 5-hour window in four hours, roughly 31%/hour, while the weekly window stayed at 15%. A pool that drains in four hours cannot host the role that is 43% of traffic. ADR-0005 put five judgment roles on it, two of which are volume roles.

3. **Copilot is a monthly credit budget, and the per-call spread is 20×.** From GitHub's billing export: 20,000 credits at $0.01 = $200, reset on the first with no rollover. Credits per call — `gpt-6-luna` 0.30, `claude-haiku-5.5` 0.36, `gpt-6.1-sol` 2.14, `claude-sonnet-5.5` 2.16, `claude-opus-5.5` 5.40. ADR-0005 said "use the model that best fits the role", which put Sol and Sonnet behind five judgment roles — 26,254 credits, **131% of the month**. That, not the pool's size, is what exhausted it on 14 November.

4. **CommandCode is the deepest pool, not the scarcest.** 15,728 requests and 2.2B tokens against a weekly limit of 30% and a monthly 38%, with $43.48 of balance left — tens of thousands of further calls at ~$0.0015 each. ADR-0005 treated it as a pool to ration.

## Decision

**Assign each role's head by its call volume measured against the headroom of each pool's limiter.**

- **Volume roles head a cheap, deep pool.** Orchestrator, at 9,353 calls/month, heads `github-copilot/gpt-6-luna` (0.30 credits/call) with `commandcode/z-ai/glm-5.3-flash` behind it. Fixer heads a free Zen model with CommandCode behind it. OpenAI never appears on a volume role, including as a fallback.
- **Judgment roles split by call count.** Oracle (1,257 calls) and council (257) head `openai/gpt-6.1-sol`; its message window stays near full because the volume is low.
- **Copilot takes the roles whose call count its budget can afford.** `gpt-6-luna` heads orchestrator and observer at 0.30/call; `gpt-6.1-sol` heads designer and `claude-sonnet-5.5` heads skeptic, where 956 and 441 calls/month keep the frontier price affordable. The allocation draws 5,804 of 20,000 credits (29%), so it survives the whole cycle.
- **Skeptic heads Copilot, not OpenAI**, so the council's three heads stay distinct and the adversarial seat runs on a different provider from the seats it challenges.
- **Mechanical roles** — explorer, observer — head free or cheap, for bounded, images-capable work.
- **Chains are three entries**: head, one alternate pool, one paygo anchor.

A preset is static configuration for a whole billing cycle, so head assignments must be affordable on the cycle's average, not on one exhausted day.

The one-entry-per-paid-provider rule from ADR-0005 stands; this ADR changes *which* provider heads *which* role, not how a descent works.

## Alternatives Considered

- **Keep ADR-0005's split (Copilot/OpenAI quality, CommandCode reach).** Rejected: measured OpenAI burn rate shows it cannot carry five roles, and Copilot's credit spread makes frontier models there 20× expensive.
- **Head every role on CommandCode's boosted models.** Rejected: it is the deepest pool, but concentrating all roles on one provider leaves the whole team dependent on a $10/mo plan's 5-hour window.
- **Drop Copilot until it resets.** Rejected: a preset is static configuration for a whole billing cycle, so removing Copilot to match one exhausted day leaves the renewed pool idle all of December. The correct response to exhaustion is to size the per-call price so the budget lasts the cycle.
- **Retain six-entry chains as deeper insurance.** Rejected: with the head running most calls, a fourth entry is unreachable, and a repeated paid provider is unreachable by the exclusion rule.

## Consequences

### Positive

- Allocation now matches measured headroom instead of intent: the 43% role sits where $43 of balance can absorb it.
- The OpenAI 5-hour window stays available for the roles whose answers it improves, instead of being drained by orchestrator.
- Copilot's empty pool costs no round-trips.
- Chains shrink from 5–6 entries to 3, so the configured intent is closer to what actually runs.

### Negative

- Orchestrator heads `gpt-6-luna` rather than a frontier model; some answers will be weaker than Sol's. This is the deliberate trade for a monthly budget that lasts the cycle — the same calls at Sol cost 20,015 credits, the entire month for one role.
- Three roles now head on Copilot, so a Copilot chargeback or plan change breaks the largest traffic share until the chains are re-pointed.

### Risks

- **Copilot is exhausted until 2026-12-01**, so the orchestrator, designer, skeptic and observer heads all fail over for the rest of this cycle. That is the cost of keeping the allocation correct for the other 29 days; the alternative stranded the pool every December.
- **Credits-per-call figures come from one 11-day window.** A change in prompt length or output verbosity moves them, and orchestrator at 9,353 calls/month is the number the whole budget rests on.
- The volume shares come from one 148k-message history and will drift. OpenAI's cost curve may be judged harshly if part of that burn was a single heavy session.
- No live failover was exercised; ordering rests on the fallback implementation's semantics, not on observed quota errors.

## References

- Chain rules: [`omp/ROUTING-CHAIN-RULES.md`](../../omp/ROUTING-CHAIN-RULES.md)
- Superseded doctrine: [ADR-0005](0005-chain-order-by-capability.md)
- Fallback semantics: `oh-my-opencode-slim/src/hooks/foreground-fallback/index.ts`
- Volume evidence: `message.data.agent` over `assistant` rows in `~/.local/share/opencode/opencode.db`
- OpenAI burn: `usage_history` in `~/.omp/agent/agent.db`, provider `openai-codex`
- Copilot credits: GitHub billing CSV, `copilot_ai_credit` rows
- CommandCode: `omp usage --json --provider commandcode --redact`
