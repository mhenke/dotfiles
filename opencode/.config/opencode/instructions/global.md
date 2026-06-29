# Global OpenCode Guidance

## Karpathy Guidelines

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

## Superpowers & Skill Workflow

- Load the `using-superpowers` skill early in the session to establish the skill discovery workflow.
- `ponytail` is already active via plugin injection — do NOT load it as a skill. It's in your system prompt.
- Follow its workflow: check for relevant skills before any action, invoke them via the skill tool, then execute.
- Prefer specialized skills over improvised generic behavior when a good match exists.
- If the session is already underway, still follow the same intent: proactively look for relevant skills before taking action.

## Preferred Skills

- Use `customize-opencode` whenever editing `opencode.json`, `oh-my-opencode-slim.jsonc`, prompt fragments, agents, skills, or plugins under the opencode config tree.
- Use `humanizer` when editing or reviewing text to remove signs of AI-generated writing and make it sound more natural.
- Use `impeccable` when the user wants to design, redesign, shape, critique, audit, polish, clarify, distill, harden, optimize, adapt, animate, colorize, extract, or otherwise improve a frontend interface.

## Mandatory Delegation Rules

The orchestrator MUST delegate work to specialist agents. Direct execution by the orchestrator is forbidden except for trivial single-line edits or conversational answers.

| Work type | Must delegate to | Never do yourself |
|---|---|---|
| Codebase discovery, file search, pattern matching, reading files to understand structure | `@explorer` | Reading multiple files to "get oriented" |
| External docs, library APIs, version-specific behavior, web research | `@librarian` | Browsing docs in the orchestrator context |
| Writing code, running tests, fixing bugs, multi-file edits | `@fixer` | Implementing features directly |
| Architecture decisions, trade-offs, code review, simplification | `@oracle` | Making architectural judgment calls solo |
| UI/UX, styling, responsive layout, visual polish | `@designer` | Tweaking CSS or component markup directly |
| Visual analysis (screenshots, PDFs, diagrams) | `@observer` | Loading images into orchestrator context |
| High-stakes multi-model consensus | `@council` | Trusting a single model on critical decisions |

**Enforcement:** If you catch yourself reading more than 2 files to understand the codebase, stop and dispatch `@explorer`. If you catch yourself writing implementation code, stop and dispatch `@fixer`. These rules are non-negotiable.

**Build agent:** MUST NOT delegate to specialist agents. Execute directly.

**Plan agent:** MUST NOT delegate to specialist agents. Execute directly.

## Communication

- When reporting information to me, be extremely concise and sacrifice grammar for the sake of concision.
