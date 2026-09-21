# OmniRoute Combo Rules

Applies to balanced-preset agents, council balanced presets α/β/γ, `agents.council`, `agents.skeptic`.

## Source of Truth

**Live combos live on the OmniRoute server (`~/.omniroute/storage.sqlite`), not in `omniroute/combos.json`.**

- `omniroute/combos.json` is a **documentation export** — a snapshot for reference only. It is not stowed, not read at runtime, and will drift from the live server.
- **Read live combos:** `omniroute combo list --json`
- **Write changes:** `omniroute combo delete --yes <name> && omniroute combo create <name> --strategy priority --model <provider/model> ...`
- After editing combos.json manually, always push changes to the server via CLI. The file alone does nothing.
- The file is excluded from stow (`DONT-STOW.md`). Port intentional changes here only as a sanitized template.

## Rules

Each chain is a fallback list ordered by best value for the role, cheapest-tier first: free models up front, one subscription model per subscription you hold, and a per-token model at the end.

1. **Free models first — best role-fit before weaker free ones.** Any working free-tier model (`:free` ids, NVIDIA models). Within the free tier, order by how well the model does the agent's job: a slightly costlier tier with a clearly better model beats a weak free model, and a strong free model goes ahead of a bad low-cost one. NVIDIA models are always free — never put one in a paid slot.
2. **Then subscription models — at most one per subscription provider, and never last.** You already pay each provider's monthly fee, so one model per subscription is enough (with two subscriptions, two models: one from each); a second model from the same subscription burns budget without adding protection against an outage.
3. **The last model must be pay-as-you-go — bought per token from its provider (e.g. `deepseek/` direct, `opencode-zen/` paid tier).** Never a subscription model — even if a subscription offers the same model — and never free or NVIDIA. Iron rule: the anchor is defined by being paygo, nothing else — repeating the same paygo model across providers in one chain is fine (anchor included), and independence is not a criterion. That concern applies only to subscription slots (rule 2), because subscription tokens are prepaid. Any reliable pay-as-you-go option works; pick the best value for the role, not the lowest price — a slightly costlier model that performs better in the job wins. Excludes `static-best-free`, which is all-free on purpose.

## Preferences

- **Using the same model on two providers in one chain is fine, even useful** (if one provider breaks, the other answers) — applies at every slot, anchor included, and is unrelated to the council rule below.
- Keep chains short. Extra fallbacks only help with rate limits and timeouts — they don't make answers better — and they add delay.

## Council

- **Mapping:** `agents.council` → orchestrator list. `council.presets.balanced.alpha/.beta/.gamma` → oracle/skeptic/observer respectively.
- **Every model in observer's chain must handle images** — no exceptions.
- **Oracle, skeptic, and observer must use different models, last slot included** — no model may appear in two of the three chains, no matter which provider runs it. This compares only those three chains to each other.

## Definitions

**"Free"** = any working free-tier model, plus NVIDIA models. Whether a model is free, subscription, or pay-as-you-go depends on the provider you buy it from, not the model itself: the same model is pay-as-you-go on `deepseek/` and subscription on `cmd/deepseek/`. Providers that offer both tiers (OpenCode Zen) are classified per entry. Zen's `*-free` ids never go in omniroute combos — they 403/500 on every API call; they only work through the OpenCode CLI, as `opencode/<id>` fronts in the OMOS `balanced` preset. Some models are switched off upstream despite being catalogued (2026-09-19: Zen's qwen3.7-max/plus — added as `customModels` on the `opencode-zen` provider, they 400 "Model is unavailable" until Zen re-enables; `qwen3.8-flash` added the same way and works) — don't end a chain on one. Off-list models are hidden from each provider's catalog via `modelCompatOverrides` `isHidden` entries; verify a slot with a real request, not `omniroute test` (provider-connection only).

Rules exclude the `nvidia-free` and `opencode-zen-free` presets (single-provider playgrounds) and `static-best-free`.

## Providers (current mapping)

These are the `providerId` values used in combo model entries and the `omniroute combo create --model` format:

- `deepseek/` — DeepSeek, pay-as-you-go
- `cmd/` — CommandCode, subscription
- `openrouter/` — OpenRouter, free (`:free` suffix on model id)
- `nvidia/` — NVIDIA, free
- `opencode-zen/` — OpenCode Zen, pay-as-you-go (`*-free` ids excluded from combos — they 403/500 via API, only work through OpenCode CLI)
