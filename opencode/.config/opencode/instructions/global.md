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

## Default Engineering Behavior

- Keep changes minimal, explicit, and easy to verify.
- Prefer direct edits over clever abstractions unless reuse is clear.
- Validate assumptions with docs, schema, or runtime checks before changing behavior.
