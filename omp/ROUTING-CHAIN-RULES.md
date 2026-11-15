# Routing Chain Rules

Chain design for the OMOS `subscription` and `balanced` presets and their council seats.

**Source of truth is the preset file**, `opencode/.config/opencode/oh-my-opencode-slim.jsonc`; the live `~/.config/opencode` copy is a symlink into this repo. There is no routing server — OmniRoute was removed 2026-11-14 — so chains are edited in that file and checked with `opencode reload`, then `opencode api GET /api/agent`.

## Chain order

A chain advances only when the current entry **fails** — error, rate limit, or exhausted allowance. Failure is the only trigger; a later entry is never tried for being better. **The head decides what runs:** it executes almost every call, so the tail is insurance, not work.

Order by what the role needs:

- **Judgment roles** — oracle, council, skeptic, designer — lead with the model that produces the best result: frontier quality, fewer retries, less churn. A stronger model that avoids one rework loop beats a free model that needs three. These roles are few calls, so they can afford the message-metered pool.
- **Volume roles** — orchestrator, fixer — lead with a capable cheap model on a deep allowance, since they run most of the traffic and a frontier head would drain a message window in hours.
- **Mechanical roles** — explorer, observer — lead with a free model; the work is bounded and a paid head buys little.
- **One paygo anchor last**, chosen as the cheapest model that still fits the role.

**Repetition follows the failure mode.** A spent allowance (`quota exceeded`, `usage limit reached`) excludes the failing provider for the rest of the descent, so a paid provider earns **one** entry: a second Copilot or OpenAI slot is unreachable. Free-tier exhaustion (`Free usage exceeded`) is classified as permanent billing instead — it fails over immediately and excludes nothing — so **free entries repeat freely**. Free Zen, free Zen, then the Zen paygo anchor is a valid shape and a cheap one.

Both semantics come from `oh-my-opencode-slim/src/hooks/foreground-fallback/index.ts`.

Classify per endpoint, not per provider: Zen serves free and paid ids, and CommandCode keeps zero-credit `:free` endpoints beside allowance-consuming ones.

## Spend doctrine

Which pool a role consumes is decided by its **head**, so the head is the only
allocation lever. Assign heads by call volume against each pool's limiter — a
pool metered in messages cannot absorb a role that is half the traffic.

Call volume, measured 2026-11-15 from `session_message` in
`~/.local/share/opencode/opencode.db` — 66,000 assistant messages over 92 days
(715/day, 21,743/month). **Never measure from the `message` table: it is the
legacy schema, frozen 2026-10-13, and reports a month of activity as absent.**

| Role | Share | Calls/mo | Tier |
|---|---|---|---|
| orchestrator | 47.0% | 10,229 | volume |
| fixer | 18.8% | 4,078 | volume |
| designer | 9.1% | 1,985 | judgment |
| oracle | 7.4% | 1,611 | judgment |
| skeptic | 6.8% | 1,488 | judgment |
| explorer | 3.2% | 685 | mechanical |
| build | 3.0% | 648 | volume |
| councillor | 1.7% | 374 | judgment |

Whole-history counts are misleading on their own: orchestrator shows 68 distinct
models, top one 15.4%. Per day it concentrates at 63–100%, so that spread is
config churn over 92 days, not per-call drift. Check concentration per day before
concluding a head is not deciding.

A role's cost is its monthly calls times its model's price, so a monthly pool and
a volume role are only compatible when the per-call price is small.

- **Volume tier heads a cheap deep pool.** CommandCode at $0.15/1M with $43 of
  remaining balance absorbs tens of thousands of calls; OpenAI's message window
  cannot. Measured: OpenAI burned 6% → 91% of its 5-hour window in four hours
  (~31%/hour). Never put OpenAI on a volume role, not even as a fallback.
- **Judgment tier spends OpenAI.** Its limits stay close to full (weekly 85%
  left) and the roles are few calls each. Frontier quality where it changes the
  answer, at the cost of the pool that can afford it.
- **Copilot is a monthly credit budget.** 20,000 credits at $0.01 = $200, reset 00:00 UTC on the first, no rollover. GitHub's billing CSV is the source of truth for it; the preset's own chains are cheap and the overrun hides outside them.
  Measured credits per call from the CSV joined to call counts: `gpt-6-luna` 0.13, `claude-haiku-5.5` 0.45, `claude-sonnet-5.5` 2.23, `gpt-6.1-sol` 2.26, `claude-opus-5.5` 6.33, `kimi-k3` 20.28.
  The preset as configured draws **9,173 credits/month (46%)**: orchestrator 10,229 calls on Luna (1,330), designer 1,985 on Sol (4,486), skeptic 1,488 on Sonnet (3,318), observer (39). Frontier sits only where monthly call counts are under 2,000; the 47%-of-traffic role heads the cheapest model.
  The exhaustion came from elsewhere: Opus 5.5 (5,686), the Code Review model (3,950) and Kimi K3 (3,387) took **65% of the month in 12 days**, and no preset chain contains any of them. Excess came from other clients and from explicit session overrides that pin a model regardless of the chain.
- **CommandCode takes boosted models only.** GLM-5.3 Flash and DeepSeek V4.1
  Flash carry $100 allowances at 0.15/1M. The $10 premium tier — GPT-6.1 Sol,
  Claude Sonnet 5.5 — is the same retail price for a tenth of the allowance;
  `zai-org/GLM-5.3` ($70) and `google/gemini-3.8-flash` ($40) are also worse per
  credit than the two boosted models.
- **Paygo anchors the chain.** Cheapest model that still fits: Zen `gpt-6-luna`
  0.10/0.50, or DeepSeek direct `deepseek-flash` 0.15/0.60 — a separate provider,
  so it survives a Zen outage.

Three entries per chain: head, one alternate pool, one anchor. Longer tails are
unreachable when the head runs most calls, and the paid-pool exclusion rule means
a fourth entry repeats a provider that is already out.

## Council

The council agent synthesizes; seats alpha/beta/gamma mirror oracle/skeptic/observer, byte-identical. Keep the council preset name in step with the active preset. Two constraints:

- Every model in the observer chain handles images.
- Oracle, skeptic, and observer take **distinct heads**, so the three verdicts do not rest on one model. Full disjointness is unreachable: three roles of three entries over four usable pools would need nine distinct models and only effort-balance allows one paid entry per provider. Distinct heads is the part that matters.

## Provider economics, measured 2026-11-15

The reasoning behind the model picks. Check live figures with `omp usage --json --provider <id> --redact`; per-model Copilot detail comes from GitHub's billing CSV export.

- **CommandCode GOAT** — $10/mo against $100 of credits, and the per-model allowances are **not** additive. GLM-5.3 Flash and DeepSeek V4.1 Flash carry $100 each, GLM-5.3 $70, Gemini 3.8 Flash $40; premium models — GPT-6.1 Sol, Claude Sonnet 5.5 — carry $10. Put a boosted model in a CommandCode slot. Gemini 4 Argon is not on GOAT. Measured 2026-11-15: 15,728 requests, 2.2B tokens, weekly limit 30%, monthly 38%, balance $43.48 — the deepest headroom of any pool.
- **Copilot Max** — $100/mo, 20,000 AI credits monthly at $0.01/credit = $200 gross, reset 00:00 UTC on the first with no rollover. Measured 2026-11-15: $200.00 gross of $200, **exhausted** until 2026-12-01. Token-priced; legacy PRU multipliers do not apply.
- **OpenAI Plus** — $20/mo sharing one 5-hour and one 7-day window with Codex and ChatGPT Work. Measured burn 6% → 91% of the 5-hour window in four hours (~31%/hour) while the weekly stayed at 15%. Fast mode burns 2.5×. API-organization credits are Pro and Business only.
- **Paygo** — Zen bills per request at catalog rates, DeepSeek direct at its own. Cheapest capable Zen: `gpt-6-luna` and `claude-haiku-5-5` at 0.10/0.50 per 1M, `glm-5.3-flash` at 0.15/0.50.

## Model evidence

- **GLM / MiMo** — [Z.ai](https://docs.z.ai/guides/vlm/glm-5.3-flash) and [Xiaomi](https://mimo.mi.com/docs/en-US/news/latest/v2-6) document agentic and visual coding; [independent comparison](https://artificialanalysis.ai/models/comparisons/mimo-v2-6-flash-vs-glm-5-3-flash) supports both, neither as a universal winner. MiMo Pro results do not transfer to Flash.
- **Big Pickle** — read-only codebase analysis, on [community SWE Atlas evidence](https://github.com/PhillipChaffee/big-pickle-swe-atlas). Historical, single-trial, anonymous backend that may have changed.
- **Nemotron 3.5 Lightning** — [NVIDIA card](https://build.nvidia.com/nvidia/nemotron-3.5-lightning-30b-a3b/modelcard). Performed under the explorer prompt; exhausted its budget as a fixer.
- **Paid families** — [GitHub's task guidance](https://docs.github.com/en/copilot/reference/ai-models/model-comparison): Sol for complex reasoning, Luna for efficient tasks, Argon for multimodal building, Sonnet for general agentic coding.
- **Free-tier data use** — Console states that several free models (Big Pickle, Iceman, MiMo, Nemotron, Inkling) may retain prompts for training during their free period.

Catalog presence does not prove inference works, and a model card's context maximum is not the deployed limit. Verify a changed route with one bounded real request and report any timeout; a small synthetic probe is regression evidence, not an agent-quality certification.
