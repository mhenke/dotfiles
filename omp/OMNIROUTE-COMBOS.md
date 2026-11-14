# OmniRoute Combo Rules

Applies to the OMOS `balanced` preset, its council seats, and the live OmniRoute combos.

## Source of Truth

**Live combos live on the OmniRoute server (`~/.omniroute/storage.sqlite`), not in `omniroute/combos.json`.**

- `omniroute/combos.json` is a **documentation export** — a snapshot for reference only. It is not stowed, not read at runtime, and will drift from the live server.
- **Read live combos:** `omniroute combo list --json`
- **Update in place:** `omniroute api combos put-api-combos-id- --id <id> --body '<json>'`. Omitted fields are preserved; a supplied `models` array replaces the chain. Keep combo IDs so existing references remain valid.
- Changing combos.json alone does nothing. Apply changes through the management API, then refresh the sanitized snapshot.
- The file is excluded from stow (`DONT-STOW.md`). Port intentional changes here only as a sanitized template.

## Rules

Updated 2026-11-14: the free, subscription, and paygo tiers are separated at the OpenCode boundary.

1. **Native Zen free first:** `opencode/<free-id>` entries lead the OMOS `balanced` chains. Verify zero catalog cost; `big-pickle` is free despite lacking a `-free` suffix.
2. **Free-only OmniRoute second:** role combos contain verified zero-credit API endpoints only: NVIDIA and role-qualified free CommandCode entries. Classify each endpoint, not the entire provider. No allowance-consuming subscription models, paygo models, or Zen endpoints belong here.
3. **Direct subscription third:** one allowance-consuming `commandcode/<model>` entry in each OMOS chain uses the CommandCode allowance. Its free endpoints inside OmniRoute do not consume that allowance.
4. **Direct paygo last:** each OMOS chain ends with an explicit paid `opencode/<model>` endpoint. Choose best value for the role, not merely the lowest price. Paid Zen is called natively through OpenCode, never through OmniRoute.

## Preferences

- Using the same model across providers is fine. The council separation rule below applies across oracle/skeptic/observer, not within one chain.
- Keep chains short. Extra fallbacks only help with rate limits and timeouts — they don't make answers better — and they add delay.

## Council

- **Mapping:** `presets.balanced.council` uses its dedicated council combo, not the orchestrator's planning model. Council seats alpha/beta/gamma use oracle/skeptic/observer respectively. The global council default should match the active balanced default; other session presets must explicitly select their council lineup.
- **Every model in observer's chain must handle images** — no exceptions.
- **Oracle, skeptic, and observer must use different models, last slot included** — no model may appear in two of the three chains, no matter which provider runs it. This compares only those three chains to each other.

## Definitions

**"Free"** depends on the endpoint, not just the provider or model family. NVIDIA is free; CommandCode has both free endpoints and allowance-consuming subscription endpoints. Paid Zen is paygo. Zen free models require native OpenCode authorization and must not be proxied through OmniRoute. Catalog presence does not prove inference works: verify changed routes with bounded real requests and disclose timeouts or failures.

The `nvidia-free` and `opencode-zen-free` presets are independent single-provider playgrounds. `static-best-free` remains free-only and has no subscription or paygo anchor.

## Providers (current mapping)

Routing namespaces used at each boundary:

- OMOS `opencode/<free-id>` — native Zen free, before OmniRoute.
- OmniRoute `nvidia/` — free API models.
- OmniRoute `cmd/thinkingmachines/inkling-2-small:free` — zero-credit research, bounded implementation, and Oracle fallback. Qualified with source tracing, exact citations, tool-schema compliance, boundary-case repair, and a transaction-review fixture; these are smoke checks, not a general reasoning certification.
- OMOS allowance-consuming `commandcode/` — direct CommandCode subscription, after OmniRoute.
- OMOS paid `opencode/` — direct Zen paygo, last.
- OmniRoute `opencode-zen/`, `deepseek/`, and allowance-consuming `cmd/` entries are excluded. The CommandCode connection is enabled only to serve explicitly free combo entries; its paid/subscription models are not added to these combos.

## Free CommandCode qualification

- [Current free-tier terms](https://commandcode.ai/docs/resources/pricing-limits#inkling-2-small-free): Inkling 2 Small costs no credits, has a daily request limit, and requires an account credit balance. The provider may retain/train on prompts; the user explicitly accepted those terms on 2026-11-14.
- Inkling passed source tracing and exact bug-location checks, timestamp repair against 25 boundary cases, and an Oracle review that identified both concurrency and interrupted-transfer failures. It also passed an image/tool check. Its inconsistent Council consensus labeling is a separate weakness; it is not used for synthesis.
- Glyph Cluster is genuinely free but failed the required function-argument schema during qualification, so it is excluded. Free pricing and catalog presence are not agent-fit evidence.

## Balanced role-fit audit

Audited against the installed `src/agents/role-prompts.ts`, `orchestrator.ts`, `council.ts`, `councillor.ts`, and the local `oh-my-opencode-slim/skeptic.md`. The effective registered prompts were checked too. Planning, implementation, visual analysis, critique, and synthesis are different jobs; an API/tool-call pass is not a role-fit pass.

The last column below applies twice: directly through CommandCode, then through native paid Zen. Free OmniRoute entries are zero-credit endpoints, never the subscription/paygo versions of the same models.

| Agent | Native Zen free front | Free OmniRoute choice | Direct subscription / final paygo family |
|---|---|---|---|
| Orchestrator | GLM-5.3-Flash high → MiMo-V2.6-Flash | Nemotron 3 Ultra | GLM-5.3-Flash high |
| Oracle / alpha | Big Pickle | Inkling 2 Small Free high | GPT-6.1 Sol high |
| Explorer | Nemotron 3.5 Lightning | Lightning → Inkling 2 Small Free | GPT-6 Luna low |
| Designer | MiMo-V2.6-Flash | MiniMax M3.1 Flash low | Gemini 4 Argon medium |
| Fixer | DeepSeek V4.1 Flash low → MiMo-V2.6-Flash | Inkling 2 Small Free low | DeepSeek V4.1 Flash low |
| Observer / gamma | MiMo-V2.6-Flash | Nemotron 3 Nano Omni | GPT-6 Luna low |
| Council synthesis | GLM-5.3-Flash high → MiMo-V2.6-Flash | MiniMax M3.1 Flash medium | GLM-5.3-Flash high |
| Skeptic / beta | DeepSeek V4.1 Flash high | MiniMax M3.1 Flash low | Claude Sonnet 5.5 high |

### Evidence and limits

- **GLM/MiMo:** [Z.ai's model guide](https://docs.z.ai/guides/vlm/glm-5.3-flash) documents goal decomposition, tool use, and visual coding; [Xiaomi's release](https://mimo.mi.com/docs/en-US/news/latest/v2-6) documents multimodal coding, agentic work, and frontend design. [Independent same-suite comparison](https://artificialanalysis.ai/models/comparisons/mimo-v2-6-flash-vs-glm-5-3-flash) supports both as capable agentic choices, not a universal winner. Do not transfer MiMo Pro-only results to Flash.
- **Beam:** [Reflection's card](https://reflection.ai/beam-model-card) supports coding/reasoning, but [independent comparison](https://artificialanalysis.ai/models/comparisons/reflection-beam-vs-mimo-v2-6-flash) shows a speed/capability tradeoff. Replaced Beam with MiMo in the central orchestrator chain; not promoting the faster model into a stronger-judgment role just because it is free.
- **Big Pickle:** retained provisionally for read-only codebase analysis using [reproducible community SWE Atlas evidence](https://github.com/PhillipChaffee/big-pickle-swe-atlas). That run is historical, self-reported, single-trial, and tied to an anonymous backend; it is not proof of today's model identity or superiority.
- **Lightning:** [NVIDIA's card](https://build.nvidia.com/nvidia/nemotron-3.5-lightning-30b-a3b/modelcard) supports efficient subagent work. The exact Explorer prompt produced correct paths/lines and distinguished unknown cache behavior. Its bounded Fixer probe exhausted the response budget without an answer; it is not retained as a coding fallback merely because it can search well.
- **Ultra:** [NVIDIA's card](https://build.nvidia.com/nvidia/nemotron-3-ultra-550b-a55b/modelcard) supports complex agentic planning. The planning fixture handled dependencies, write ownership, and evidence. A transaction review and Council example exposed correctness weaknesses, so it remains a planning fallback, not the Oracle/synthesizer.
- **Inkling versus Laguna:** [shared published coding rows](https://benchlm.ai/compare/inkling-2-small-vs-laguna-xs-2-1) favor Inkling, but the comparison explicitly warns against a broad winner from sparse overlap. Combined with the local repair failure for Laguna and passing Inkling boundary checks, this supports the scoped replacement, not a global ranking. Glyph's malformed tool arguments exclude that deployed endpoint; no unsupported model-identity claim is needed.
- **Vision versus design:** Nano Omni extracted exact screenshot error/path text, but its UI implementation suggestion left a clickable `div`; keep it as Observer, not Designer. MiniMax at low effort returned a native button, responsive sizing, concrete recovery changes, and an honest verification limit; it also followed all five Skeptic stages. [Independent MiniMax evaluation](https://artificialanalysis.ai/models/minimax-m3-1-flash) supports agentic/knowledge-work capability but warns about verbosity and latency. Full Council inference was inconclusive; its synthesis assignment is documented/benchmark-supported, not a claimed live pass.
- **Paid/subscription families:** [current task guidance](https://docs.github.com/en/copilot/reference/ai-models/model-comparison) supports Sol for complex coding/reasoning, Luna for efficient smaller tasks, Argon for complex multimodal building, and Sonnet for general agentic coding. [DeepSeek's model card](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash) supports scoped coding. These are model-family characteristics, not Copilot billing rules or proof that hosted tools are exposed by CommandCode/Zen. Provider IDs, image input, tools, and advertised variants are checked separately in the live registry. No paid inference benchmark was run.

Native Zen's free-usage limit blocked the attempted Big Pickle probe; it fell back to OmniRoute. That output was attributed to the fallback, never counted as a Big Pickle pass. Model-card context maxima are not assumed to be the deployed endpoint limits. Small synthetic probes are regression evidence, not comprehensive agent-quality certification; do not promote isolated failures into universal rankings either.
