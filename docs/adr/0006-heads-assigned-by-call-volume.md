# ADR-0006: Assign Heads by Call Volume Against Each Pool's Limiter

## Status

Accepted 2026-11-15. Amends [ADR-0005](0005-chain-order-by-capability.md), whose spend doctrine it replaces.

## Context

ADR-0005 ordered chains by role capability and split the pools by intent: Copilot and OpenAI "buy quality" and should be spent freely, CommandCode "buys reach" and should be stretched. That split assumed the pools were interchangeable, differing only in how much we cared about the price.

Four measurements taken 2026-11-15 show the pools are not interchangeable, and that ADR-0005's doctrine misallocated them.

1. **Call volume is extremely uneven.** Over 148,484 assistant messages, orchestrator alone is 43.3%, `build` 16.6%, fixer 12.8%; oracle 5.8%, explorer 5.6%, designer 4.4%, skeptic 2.0%, council 1.2%. Since the head runs nearly every call, the head assignment *is* the allocation.

2. **OpenAI is metered in messages and burns fast.** Sampled every hour: 6% → 37% → 64% → 84% → 91% of the 5-hour window in four hours, roughly 31%/hour, while the weekly window stayed at 15%. A pool that drains in four hours cannot host the role that is 43% of traffic. ADR-0005 put five judgment roles on it, two of which are volume roles.

3. **Copilot prices its models in credits, and the spread is 20×.** From GitHub's billing export: 20,000 credits at $0.01 = $200. Output tokens per credit dollar — Luna 326k, Haiku 5.5 128k, Sonnet 5.5 28k, Sol 14.8k, Opus 5.5 9.6k. Gross reached $200.00 of $200 before the December reset. ADR-0005's "use the model that best fits the role" put Sol and Sonnet there, at 20× the credit cost for the same budget.

4. **CommandCode is the deepest pool, not the scarcest.** 15,728 requests and 2.2B tokens against a weekly limit of 30% and a monthly 38%, with $43.48 of balance left — tens of thousands of further calls at ~$0.0015 each. ADR-0005 treated it as a pool to ration.

## Decision

**Assign each role's head by its call volume measured against the headroom of each pool's limiter.**

- **Volume roles** — orchestrator, fixer — head on a deep, cheap pool: CommandCode `z-ai/glm-5.3-flash` at 0.15/0.50, or a free Zen model for the mechanical end. OpenAI never appears on a volume role, including as a fallback.
- **Judgment roles** — oracle, designer, council — head on `openai/gpt-6.1-sol`. Few calls each, close to full windows, and the quality changes the answer.
- **Skeptic** heads on `commandcode/deepseek/deepseek-v4.1-flash` rather than OpenAI, so the council's three heads stay distinct and the adversarial seat runs on a different provider from the seats it challenges.
- **Mechanical roles** — explorer, observer — head free, for images-capable cheap work.
- **Copilot carries no slot** while its credits are exhausted; when it resets it returns as a cheap-tier alternate only (`claude-haiku-5.5`, `gpt-6-luna`), never a frontier model.
- **Chains are three entries**: head, one alternate pool, one paygo anchor.

The one-entry-per-paid-provider rule from ADR-0005 stands; this ADR changes *which* provider heads *which* role, not how a descent works.

## Alternatives Considered

- **Keep ADR-0005's split (Copilot/OpenAI quality, CommandCode reach).** Rejected: measured OpenAI burn rate shows it cannot carry five roles, and Copilot's credit spread makes frontier models there 20× expensive.
- **Head every role on CommandCode's boosted models.** Rejected: it is the deepest pool, but concentrating all roles on one provider leaves the whole team dependent on a $10/mo plan's 5-hour window.
- **Keep Copilot on roles and accept failed round-trips until 1 December.** Rejected: a spent allowance excludes the provider for the remaining descent, so each Copilot head burns a request to fail immediately for three weeks.
- **Retain six-entry chains as deeper insurance.** Rejected: with the head running most calls, a fourth entry is unreachable, and a repeated paid provider is unreachable by the exclusion rule.

## Consequences

### Positive

- Allocation now matches measured headroom instead of intent: the 43% role sits where $43 of balance can absorb it.
- The OpenAI 5-hour window stays available for the roles whose answers it improves, instead of being drained by orchestrator.
- Copilot's empty pool costs no round-trips.
- Chains shrink from 5–6 entries to 3, so the configured intent is closer to what actually runs.

### Negative

- Orchestrator leaves frontier quality for `glm-5.3-flash`; some answers will be weaker than Sol's. This is the deliberate trade for not exhausting OpenAI before noon.
- The whole team now depends on CommandCode, a $10/mo plan whose 5-hour window is one pool.

### Risks

- **CommandCode 5-hour exhaustion now degrades the whole team**, not one role. The free-Zen second entry absorbs it, but at a quality cost.
- **Copilot returns on 2026-12-01** and these chains carry no slot for it; the preset needs revisiting then, or the renewed pool idles.
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
