# Routing Chain Rules

Chain design for the OMOS `subscription` and `balanced` presets and their council seats.

**Source of truth is the preset file**, `opencode/.config/opencode/oh-my-opencode-slim.jsonc`; the live `~/.config/opencode` copy is a symlink into this repo. There is no routing server — OmniRoute was removed 2026-11-14 — so chains are edited in that file and checked with `opencode reload`, then `opencode api GET /api/agent`.

## The pool and the cap

**A provider's credits are ONE shared pool. A per-model allowance is a ceiling on what that model may draw from it, never a separate budget.**

This is the most misread thing about every subscription here, and reading it the other way multiplies the apparent budget. Command Code's own docs: *"you can use 14 credits in any 5 hours and 35 in any 7 days, no matter which models you mix … and all the slices add up to one plan."*

| | Amount | Scope |
|---|---|---|
| Monthly pool | 70 credits | **one pool**, shared by every model |
| 5-hour window | 14 credits | **pool-wide** |
| Weekly window | 35 credits | **pool-wide** |
| Per-model allowance | $10–$100 | **ceiling** on that model's draw |

A credit is a usage-value unit, not a dollar: 14 credits is $20 of usage on a $100-allowance model and $14 on a $70 one. That is why `omp usage` reports `used 10.55 / limit 35`.

Three models with $20 allowances do not give $60. They share the pool, each individually capped, and a burst on any one consumes the same 5-hour budget. Copilot's 20,000 credits and OpenAI's message windows have the same shape.

The consequence drives everything below: **compare models by cost per call, because every call comes from the same pool.** A cheaper model stretches it; a bigger allowance on an expensive model creates no more.

## Two spend layers

Copilot's pool is consumed by **two independent paths**, and only one is this preset. Measured 2026-11-15:

| Path | Calls/mo | Copilot credits | Controlled by |
|---|---|---|---|
| Orchestrator | 13,841 | **11,785 (59%)** | `opencode.json` model + `/model` |
| Subagent chains | 11,549 | 7,843 (39%) | **this preset** |
| | | **19,628 = 98%** | |

So the preset's own chains are under half the bill, and the orchestrator is the larger consumer despite having no head. Its last-seven-day mix was `claude-haiku-5.5` 80.9%, `claude-opus-5.5` 7.7%, `glm-5.3-flash-free` 5.5%. Opus at 6.33 credits/call is **6,746 credits, 34% of the monthly pool, for 7.7% of calls** — the single largest line item anywhere.

Only **53% of traffic is allocatable** by a preset: 34,951 of 66,000 calls are subagents, or 11,549/month. Any capacity math against the full 20,450 overstates what a chain can reach.

| Pool | Capacity at a viable model | vs 11,549 allocatable |
|---|---|---|
| Copilot @ `gpt-6.1-terra` | 17,544 calls | 1.5× |
| Copilot @ `gpt-6-luna` | 153,846 calls | 13× |
| OpenAI Pro @ `gpt-6.1-sol` | 132,333 calls | 11× |
| CommandCode @ `glm-5.3-flash` | 70,922 calls | 6× |

The subscription pools supply ~374,000 calls against 11,549 the preset can direct — **32× oversupplied**. So the framing is not "spend every pool" but **which pool to leave unused**, and expiring prepaid credits cost nothing. Prefer the arrangement that puts the strongest model on the least mechanical work, and let the rest act as failure insurance.

## Chain order

A chain advances only when the current entry **fails** — error, rate limit, or exhausted allowance. Never for being better.

**The orchestrator has no head.** Its array is a fallback list only, and this is deliberate upstream (`src/agents/index.ts:203`, #9100e59 / #639): `config.model` stays undefined for the orchestrator so a live `/model` selection survives the plugin re-inits that fire on every subagent dispatch. `foreground-fallback` then lets the session model lead the descent, with the configured entries backing it (`index.ts:4439`).

So for the orchestrator, **the session model decides what runs**; slot 0 is the first thing tried after it fails. Choosing an orchestrator "head" in the preset changes nothing until a failure. Measured over the last month, its actual models were `copilot/claude-haiku-5.5` 42.3%, `xiaomi/mimo-v2.6-pro` 19.6%, `beam-free` 15.0% — none of them a configured entry.

Subagents are different: they are ephemeral, so `config.model` is set to the array's first entry at launch and the rest stay as the fallback chain (`src/agents/registry.ts:174`). **Their heads bind.**

Order by what the role needs:

- **Judgment roles** — oracle, council, skeptic, designer — lead frontier. Few calls each, and quality changes the answer.
- **Volume roles** — fixer, build — lead a cheap model on a deep allowance. They carry the traffic, and a frontier head would drain a message window in hours.
- **Mechanical roles** — explorer, observer — lead free or near-free; the work is bounded.
- **One metered anchor last**, preceded by a free entry, so the only per-token entry is reached solely when the free tier has already failed.

**Repetition follows the failure mode.** A spent allowance (`quota exceeded`, `usage limit reached`) excludes the failing provider for the rest of the descent, so a subscription provider earns **one** entry: a second Copilot or OpenAI slot is unreachable. Free-tier exhaustion (`Free usage exceeded`) is classified as permanent billing instead — it fails over immediately and excludes nothing — so **free entries repeat freely**. Free Zen, free Zen, then the Zen paygo anchor is a valid shape and a cheap one.

Both semantics come from `oh-my-opencode-slim/src/hooks/foreground-fallback/index.ts`.

Classify per endpoint, not per provider: Zen serves free and paid ids, and CommandCode keeps zero-credit `:free` endpoints beside allowance-consuming ones.

Four entries per chain, in cost order after the head: **head → subscription alternate → free tier → metered anchor.**

The order is the point. A head that suits the role runs nearly every call. Behind it, subscription pools are already paid for, so they go next. Free entries cost nothing and exist to keep work off the metered pool — an entry is only reached after everything ahead of it fails, so a free step there is free insurance that pays for itself the first time a subscription pool is spent. The metered anchor is last because it is the only entry that bills per token.

**Free tier is a cost shield, and its position says which cost it shields.** Immediately before the metered anchor it protects real money. At the head of a mechanical role — explorer, fixer — it protects the subscription pools as well, because the traffic never reaches a paid tier at all. That is the whole difference between the presets: `subscription` pays for judgment heads and shields the tail; `balanced` heads everything on free, so it minimises subscription spend too and accepts weaker answers.

What free tier must not do is head a judgment role. Measured over 65,774 steps, free-first left subscriptions at 18.7% of steps while the head ran nearly everything — the weakest model sat in the only position that reliably executes.

## Assigning heads by volume

For a subagent, the head decides spend, so head assignment *is* the allocation. Assign by call volume against each pool's limiter: a pool metered in messages cannot absorb a role that is half the traffic. The orchestrator is the exception — the session model spends, not the chain (see above), so its allocation is decided by whatever `opencode.json` or `/model` selects.

Measured 2026-11-15 from `session_message` — 66,000 assistant messages over 92 days (21,743/month).

| Role | Share | Calls/mo | Tier |
|---|---|---|---|
| orchestrator | 47.0% | 10,229 | *not preset-governed* |
| fixer | 18.8% | 4,078 | volume |
| designer | 9.1% | 1,985 | judgment |
| oracle | 7.4% | 1,611 | judgment |
| skeptic | 6.8% | 1,488 | judgment |
| explorer | 3.2% | 685 | mechanical |
| build | 3.0% | 648 | volume |
| councillor | 1.7% | 374 | judgment |

**Measure from `session_message`, never `message`.** `message` is the OpenCode v1 schema: after the v2 switch on 2026-08-14 OpenCode dual-wrote to both until its last legacy write on 2026-10-13, so it holds 40,094 exact-timestamp duplicates *and* stops a month short — 148,484 messages over 209 days, inflating volume while hiding recent activity.

Whole-history counts mislead on their own. Orchestrator shows 68 distinct models with a 15.4% top share; per day it concentrates at 63–100%. Check concentration per day before concluding a chain is not deciding — though for the orchestrator the explanation is the missing head, not churn.

A role's cost is its monthly calls times its model's price, so a monthly pool and a volume role are only compatible when the per-call price is small.

Variants follow what the role is *for*, not its turn structure. Designer is 95% prose turns (5,742 against 283 tool calls), so its head takes `high`. Oracle and skeptic are 90–94% tool calls, but those calls are the evidence-gathering of a verdict the user deliberately invoked — an oracle asked to review something reads many files and answers once. Counting turns against them would price the working that makes the verdict good, so they take `high` too.

| Role | Tool calls | Prose turns | Variant |
|---|---|---|---|
| designer | 283 | 5,742 | high |
| orchestrator | 21,279 | 9,770 | *session-set* |
| oracle | 4,425 | 465 | high |
| skeptic | 4,230 | 288 | high |
| fixer | 8,674 | 3,705 | low |
| explorer | 1,746 | 334 | default |

The no-finish rows were checked rather than assumed: designer's are 5,718 prose against 9 toolish, so the prose share is real, not an artifact of missing markers.

## Provider economics, measured 2026-11-15

Check live figures with `omp usage --json --provider <id> --redact`; per-model Copilot detail comes from GitHub's billing CSV export, which is its source of truth.

- **CommandCode GOAT** — $10/mo for the 70-credit pool above. Per-model caps: DeepSeek V4.1 Flash and GLM-5.3 Flash $100, `meta/muse-spark-1.3-contributor` $20, GLM-5.3 $70, Gemini 3.8 Flash $40, premium GPT-6.1 Sol and Claude Sonnet 5.5 $10. Gemini 4 Argon is not on GOAT. Deepest headroom of any pool: weekly 30%, monthly 38%, balance $43.48.
  Cost per call on our traffic: `muse-spark-1.3-contributor` $0.00086, `deepseek-v4.1-flash` $0.00088, `z-ai/glm-5.3-flash` $0.00141. Cache-read price drives it — $0.002/M for Muse Contributor against $0.003 for DeepSeek and $0.030 for GLM Flash — and agent loops are cache-dominated.
  So a $20 cap is generous on a cheap model: at 0.00086/call it covers ~23,000 calls before binding, well beyond the low-volume visual roles it serves. `muse-spark-1.3-contributor` heads observer and backs designer; the $100-allowance DeepSeek and GLM Flash models carry the traffic-heavy slots. A $10 premium model in a slot is the worst pick: same retail price, a tenth of the cap.
- **Copilot Max** — 20,000 credits at $0.01 = $200 in one pool, reset 00:00 UTC on the first, no rollover. **Exhausted until 2026-12-01**: $200.00 gross of $200. Credits per call from the CSV: `gpt-6-luna` 0.13, `claude-haiku-5.5` 0.45, `claude-sonnet-5.5` 2.23, `gpt-6.1-sol` 2.26, `claude-opus-5.5` 6.33, `kimi-k3` 20.28.
  The preset draws **7,843 credits/month (39%)**: designer 1,985 calls on Sol (4,486), skeptic 1,488 on Sonnet (3,318). Observer sits on CommandCode instead.
  The orchestrator adds **11,785 (59%)** from outside the preset, taking the pool to 98% when both run. `claude-opus-5.5` is 6,746 of that — 34% of the month for 7.7% of orchestrator calls. Pointing the orchestrator at a cheaper model is therefore the highest-leverage Copilot saving available, and it is a one-line change in `opencode.json`, not a chain edit.
  What exhausted the pool was elsewhere: Opus 5.5 (5,686), the Code Review model (3,950) and Kimi K3 (3,387) took **65% of the month in 12 days**, and no chain contains any of them. Overrun comes from other clients and from session overrides that pin a model regardless of the chain.
- **OpenAI Plus** — $20/mo sharing one 5-hour and one 7-day window with Codex and ChatGPT Work, metered in messages. Measured burn: 6% → 91% of the 5-hour window in four hours (~31%/hour) while the weekly stayed at 15%. **Never put OpenAI on a volume role, not even as a fallback.** Fast mode burns 2.5×. Judgment roles only, where the few calls each keep it near full.
- **Paygo** — Zen bills per request at catalog rates, DeepSeek direct at its own. Cheapest capable Zen: `gpt-6-luna` 0.10/0.50, `glm-5.3-flash` 0.15/0.50. `deepseek-flash` 0.15/0.60 is a separate provider, so it survives a Zen outage.

## Custom agents

A custom agent needs three things to exist, and `orchestratorPrompt` decides whether the orchestrator can reach it. Both are deliberate choices, not one best practice:

| Requirement | Where | Failure without it |
|---|---|---|
| `agents.<name>` entry | **top-level** `agents` record | never inferred as custom (`src/config/utils.ts:79`) |
| `model` | same entry | agent skipped, warning only (`src/agents/index.ts:1188`) |
| prompt file | `<config dir>/oh-my-opencode-slim/<name>.md` | runs with no system prompt |

**`orchestratorPrompt` puts an agent on the roster.** It renders into the orchestrator's `<Agents>` block (`src/agents/index.ts:1489`), and a block lists only agents that supply one. Omit it and the agent registers, runs, and is never chosen — reachable only when the user invokes it with `@name`.

That is the right shape for an agent the user reaches for deliberately. It is the wrong shape for one meant to be delegated to.

**Blocking delegation as well, not just hiding it.** Omitting `orchestratorPrompt` keeps the agent out of the prompt but leaves the `task` tool able to call it. Add it to the orchestrator's allowlist to make the refusal structural:

```jsonc
"agents": {
  "orchestrator": {
    "subagents": ["explorer", "oracle", "designer", "fixer", "observer", "council"]
  }
}
```

The list compiles into the `task` permission stance and renders the scoped catalog (`src/agents/index.ts:1396`). Anything absent is not delegatable, whatever the prompt says.

Verify from the live prompt, never from the config:

```bash
opencode api GET /api/agent \
  | jq -r '.. | objects | select(.name=="orchestrator") | .system' \
  | grep -oE '^@[a-z-]+' | sort -u
```

A schema pass proves nothing: it validates whether or not the agent is built, and says nothing about wiring.

### `archon`

The escalation tier, off the roster and invoked only with `@archon`: `github-copilot/claude-opus-5.5` → `openai/gpt-6-astra` → `commandcode/z-ai/glm-5.3-flash` → `opencode/gpt-6-luna`, all at `high`.

It exists because a frontier model left pinned as the session default spends the pool on ordinary turns. Measured 2026-11-15: Opus on orchestrator was 7.7% of its calls but **6,746 credits, 34% of the monthly pool**. The same model, reached on purpose for a decision that smaller agents could not settle, is worth that price; idling on it is not. Astra takes the OpenAI slot as the highest tier there, noting `gpt-6.1-sol` has the larger context (628k against 400k) when length matters more than depth.

## Council

The council agent synthesizes; seats alpha/beta/gamma mirror oracle/skeptic/observer, byte-identical. Keep the council preset name in step with the active preset. Two constraints:

- Every model in the observer chain handles images.
- Oracle, skeptic, and observer take **distinct heads**, so the three verdicts do not rest on one model. Full disjointness is unreachable: three roles of three entries over four usable pools needs nine distinct models, while the one-entry-per-subscription-provider rule allows one per provider. Distinct heads is the part that matters.

## Model evidence

- **GLM / MiMo** — [Z.ai](https://docs.z.ai/guides/vlm/glm-5.3-flash) and [Xiaomi](https://mimo.mi.com/docs/en-US/news/latest/v2-6) document agentic and visual coding; [independent comparison](https://artificialanalysis.ai/models/comparisons/mimo-v2-6-flash-vs-glm-5-3-flash) supports both, neither as a universal winner. MiMo Pro results do not transfer to Flash.
- **Big Pickle** — read-only codebase analysis, on [community SWE Atlas evidence](https://github.com/PhillipChaffee/big-pickle-swe-atlas). Historical, single-trial, anonymous backend that may have changed.
- **Nemotron 3.5 Lightning** — [NVIDIA card](https://build.nvidia.com/nvidia/nemotron-3.5-lightning-30b-a3b/modelcard). Performed under the explorer prompt; exhausted its budget as a fixer.
- **Paid families** — [GitHub's task guidance](https://docs.github.com/en/copilot/reference/ai-models/model-comparison): Sol for complex reasoning, Luna for efficient tasks, Argon for multimodal building, Sonnet for general agentic coding.
- **Free-tier data use** — Console states that several free models (Big Pickle, Iceman, MiMo, Nemotron, Inkling) may retain prompts for training during their free period.

Catalog presence does not prove inference works, and a model card's context maximum is not the deployed limit. Verify a changed route with one bounded real request and report any timeout; a small synthetic probe is regression evidence, not an agent-quality certification.
