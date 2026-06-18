# Global OpenCode Guidance

## Skill-First Workflow

- Before coding, reviewing, refactoring, or changing configuration, check whether a relevant installed skill should be loaded first.
- Prefer specialized skills over improvised generic behavior when a good match exists.

## Preferred Skills

- Use `karpathy-guidelines` for implementation, refactoring, debugging, and review work where smaller, more surgical changes matter.
- Use `customize-opencode` whenever editing `opencode.json`, `oh-my-opencode-slim.jsonc`, prompt fragments, agents, skills, or plugins under the opencode config tree.
- Use `verification-before-completion` before claiming config or code changes are complete.

## Superpowers Compatibility

- If `using-superpowers` is available and it makes sense to load it early in the session, do so.
- If the session is already underway, still follow the same intent: proactively look for relevant skills before taking action.

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

## Default Engineering Behavior

- Keep changes minimal, explicit, and easy to verify.
- Prefer direct edits over clever abstractions unless reuse is clear.
- Validate assumptions with docs, schema, or runtime checks before changing behavior.
