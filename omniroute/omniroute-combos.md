# OmniRoute Routing Combos — Reference

OmniRoute is an AI model routing gateway. This document describes the 8 routing combos configured for the oh-my-opencode-slim agent setup. Each combo is a priority-ordered fallback chain: OmniRoute tries the first model; if it fails, it moves to the next.

## Routing pattern

| Priority | Provider tier | Purpose |
|----------|--------------|---------|
| 1 | OpenCode Zen free | Zero-cost primary (mimo-v2.5-free, big-pickle, muse-spark) |
| 2 | NVIDIA NIM | Free NIM cushion for heavier roles |
| 3 | CommandCode GoAT | Paid subscription models (deepseek, qwen, minimax) |
| 4 | OpenCode paygo | Final keep-the-lights-on fallback |

Note: opencode-go was replaced by commandcode (GoAT plan). OpenCode Free tier (oc/) was replaced by opencode-zen free models. Laguna S 2.1 is the only truly free commandcode model, but free opencode-zen models are preferred.

## Combo: designer

- **Strategy:** priority
- **Model count:** 3

| Position | Model ID | Provider |
|----------|----------|----------|
| 1 | `opencode-zen/mimo-v2.5-free` | opencode-zen |
| 2 | `nvidia/moonshotai/kimi-k3` | nvidia |
| 3 | `opencode-zen/big-pickle` | opencode-zen |

## Combo: explorer

- **Strategy:** priority
- **Model count:** 2

| Position | Model ID | Provider |
|----------|----------|----------|
| 1 | `opencode-zen/mimo-v2.5-free` | opencode-zen |
| 2 | `cmd/deepseek/deepseek-v4-flash` | cmd |

## Combo: fixer

- **Strategy:** priority
- **Model count:** 2

| Position | Model ID | Provider |
|----------|----------|----------|
| 1 | `opencode-zen/mimo-v2.5-free` | opencode-zen |
| 2 | `cmd/deepseek/deepseek-v4-flash` | cmd |

## Combo: librarian

- **Strategy:** priority
- **Model count:** 3

| Position | Model ID | Provider |
|----------|----------|----------|
| 1 | `opencode-zen/mimo-v2.5-free` | opencode-zen |
| 2 | `cmd/xiaomi/mimo-v2.5` | cmd |
| 3 | `opencode-zen/ling-3.0-flash-fin-free` | opencode-zen |

## Combo: observer

- **Strategy:** priority
- **Model count:** 3

| Position | Model ID | Provider |
|----------|----------|----------|
| 1 | `opencode-zen/mimo-v2.5-free` | opencode-zen |
| 2 | `cmd/xiaomi/mimo-v2.5` | cmd |
| 3 | `opencode-zen/ling-3.0-flash-fin-free` | opencode-zen |

## Combo: oracle

- **Strategy:** priority
- **Model count:** 4

| Position | Model ID | Provider |
|----------|----------|----------|
| 1 | `opencode-zen/big-pickle` | opencode-zen |
| 2 | `nvidia/moonshotai/kimi-k3` | nvidia |
| 3 | `nvidia/deepseek-ai/deepseek-v4-pro-0813` | nvidia |
| 4 | `cmd/deepseek/deepseek-v4-pro` | cmd |

## Combo: orchestrator

- **Strategy:** priority
- **Model count:** 5

| Position | Model ID | Provider |
|----------|----------|----------|
| 1 | `opencode-zen/mimo-v2.5-free` | opencode-zen |
| 2 | `nvidia/nvidia/nemotron-3-super-120b-a12b` | nvidia |
| 3 | `nvidia/nvidia/nemotron-3.5-lightning-30b-a3b` | nvidia |
| 4 | `cmd/deepseek/deepseek-v4-flash` | cmd |
| 5 | `opencode/deepseek-v4-flash` | opencode |

## Combo: skeptic

- **Strategy:** priority
- **Model count:** 4

| Position | Model ID | Provider |
|----------|----------|----------|
| 1 | `opencode-zen/muse-spark-1.2-contributor-free` | opencode-zen |
| 2 | `opencode-zen/nemotron-3-ultra-free` | opencode-zen |
| 3 | `cmd/Qwen/Qwen3.7-Plus` | cmd |
| 4 | `opencode-zen/opencode/qwen3.7-plus` | opencode-zen |

## Role purposes

### designer
UI/UX design. mimo-v2.5-free lead, kimi-k3, big-pickle fallback.

### explorer
Fast codebase exploration. mimo-v2.5-free lead, commandcode deepseek-v4-flash.

### fixer
Bug fixing. mimo-v2.5-free lead, commandcode deepseek-v4-flash.

### librarian
Research / retrieval. mimo-v2.5-free lead, commandcode mimo-v2.5, ling-3.0-flash-fin-free.

### observer
Monitoring. mimo-v2.5-free lead, commandcode mimo-v2.5, ling-3.0-flash-fin-free.

### oracle
Heavy reasoning / deep analysis. big-pickle lead, kimi-k3 + nvidia deepseek-v4-pro, commandcode deepseek-v4-pro.

### orchestrator
Main agent — drives all delegation. Fast free lead (mimo-v2.5-free), NVIDIA NIM cushion, commandcode deepseek fallback, opencode paygo last resort.

### skeptic
Critical reviewer — challenges assumptions, finds flaws. muse-spark + nemotron-ultra free leads, commandcode qwen3.7-plus, opencode-zen qwen3.7-plus paygo.

## Council member mapping (balanced preset)

| Member | Maps to combo |
|--------|---------------|
| alpha | oracle |
| beta | skeptic |
| gamma | observer |
| council | orchestrator |
