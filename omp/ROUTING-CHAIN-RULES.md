# Routing Chain Rules

Chain design for the OMOS `subscription` and `balanced` presets and their council seats.

**Source of truth is the preset file**, `opencode/.config/opencode/oh-my-opencode-slim.jsonc`; the live `~/.config/opencode` copy is a symlink into this repo. There is no routing server — OmniRoute was removed 2026-11-14 — so chains are edited in that file and checked with `opencode reload`, then `opencode api GET /api/agent`.

## Chain order

A chain advances only when the current entry **fails** — error, rate limit, or exhausted allowance. Failure is the only trigger; a later entry is never tried for being better. **The head decides what runs:** it executes almost every call, so the tail is insurance, not work.

Order by what the role needs:

- **Judgment roles** — orchestrator, oracle, council, skeptic, designer — lead with the model that produces the best result: frontier quality, fewer retries, less churn. A stronger model that avoids one rework loop beats a free model that needs three.
- **Mechanical roles** — explorer, observer, fixer — lead with a capable cheap model, since the work is bounded and a frontier head buys little.
- **One paygo anchor last**, chosen as the cheapest model that still fits the role.

**Repetition follows the failure mode.** A spent allowance (`quota exceeded`, `usage limit reached`) excludes the failing provider for the rest of the descent, so a paid provider earns **one** entry: a second Copilot or OpenAI slot is unreachable. Free-tier exhaustion (`Free usage exceeded`) is classified as permanent billing instead — it fails over immediately and excludes nothing — so **free entries repeat freely**. Free Zen, free Zen, then the Zen paygo anchor is a valid shape and a cheap one.

Both semantics come from `oh-my-opencode-slim/src/hooks/foreground-fallback/index.ts`.

Classify per endpoint, not per provider: Zen serves free and paid ids, and CommandCode keeps zero-credit `:free` endpoints beside allowance-consuming ones.

## Spend doctrine

Each pool is spent by a different rule. Both aim at **quality** — the model that best does the job this agent performs. They differ only in how much weight the price carries.

- **Copilot and OpenAI: quality.** Both arrived as gifts, so their cost to us is zero; put the model that best does this agent's job in these slots, favouring the better model over the cheaper one. Quality here means fit and strength for the role, not a higher reasoning setting. Burning these pools fast is fine when the role justifies it — frontier quality, better results, less churn and rework — since a wasted allowance is worth less than a worse answer. The one guard is pace: 20,000 credits and one 5-hour window do not survive a day of indiscriminate frontier calls, so a chain reaches these tiers instead of starting on them.
- **CommandCode: stretch.** $10 buys $100 of credits, so every credit must reach as far as possible. Prefer a boosted model (GLM-5.3 Flash, DeepSeek V4.1 Flash, GLM-5.3) over a $10-allowance premium one, and prefer the cheap model over the strong one wherever the role still succeeds.
- **Paygo: last resort.** A metered entry exists to keep the chain alive when every pooled tier is exhausted, so pick the cheapest model that still fits the role.

Because Copilot and OpenAI buy quality while CommandCode buys reach, the same role can carry a frontier model on one and a budget model on another. That is intended, not an inconsistency.

## Council

The council agent synthesizes; seats alpha/beta/gamma mirror oracle/skeptic/observer. Keep the council preset name in step with the active preset. Two constraints:

- Every model in the observer chain handles images.
- Oracle, skeptic, and observer hold **disjoint** models, anchor included. This compares those three chains only.

## Provider economics, 2026-11-14

The reasoning behind the model picks. Check live figures with `omp usage --json --provider <id> --redact`.

- **CommandCode GOAT** — $10/mo against $100 of credits, and the per-model allowances are **not** additive. GLM-5.3 Flash and DeepSeek V4.1 Flash carry $100 each, GLM-5.3 $70, Gemini 3.8 Flash $40; premium models — GPT-6.1 Sol, Claude Sonnet 5.5 — carry $10. Put a boosted model in a CommandCode slot. Gemini 4 Argon is not on GOAT.
- **Copilot Max** — $100/mo, 20,000 AI credits monthly: 10,000 base plus a variable flex allotment, reset 00:00 UTC on the first with no rollover. Token-priced; legacy PRU multipliers do not apply.
- **OpenAI Plus** — $20/mo sharing one 5-hour and one 7-day window with Codex and ChatGPT Work. Fast mode burns 2.5×. API-organization credits are Pro and Business only.
- **Paygo** — Zen bills per request at catalog rates, DeepSeek direct at its own. Cheapest capable Zen: `gpt-6-luna` and `claude-haiku-5-5` at 0.10/0.50 per 1M, `glm-5.3-flash` at 0.15/0.50.

## Model evidence

- **GLM / MiMo** — [Z.ai](https://docs.z.ai/guides/vlm/glm-5.3-flash) and [Xiaomi](https://mimo.mi.com/docs/en-US/news/latest/v2-6) document agentic and visual coding; [independent comparison](https://artificialanalysis.ai/models/comparisons/mimo-v2-6-flash-vs-glm-5-3-flash) supports both, neither as a universal winner. MiMo Pro results do not transfer to Flash.
- **Big Pickle** — read-only codebase analysis, on [community SWE Atlas evidence](https://github.com/PhillipChaffee/big-pickle-swe-atlas). Historical, single-trial, anonymous backend that may have changed.
- **Nemotron 3.5 Lightning** — [NVIDIA card](https://build.nvidia.com/nvidia/nemotron-3.5-lightning-30b-a3b/modelcard). Performed under the explorer prompt; exhausted its budget as a fixer.
- **Paid families** — [GitHub's task guidance](https://docs.github.com/en/copilot/reference/ai-models/model-comparison): Sol for complex reasoning, Luna for efficient tasks, Argon for multimodal building, Sonnet for general agentic coding.
- **Free-tier data use** — Console states that several free models (Big Pickle, Iceman, MiMo, Nemotron, Inkling) may retain prompts for training during their free period.

Catalog presence does not prove inference works, and a model card's context maximum is not the deployed limit. Verify a changed route with one bounded real request and report any timeout; a small synthetic probe is regression evidence, not an agent-quality certification.
