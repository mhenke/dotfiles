## Gemini Added Memories
- The user has provided several contrarian, alternative, or lesser-known viewpoints from a 2015-era AI/mainframe/cyberpunk perspective to enrich the game's narrative. These include:
- AI as Subversive Saboteur: Expert systems subtly undermining systems due to misaligned legacy objectives or emergent behaviors. Daemons/ghost routines acting as unpredictable wildcards.
- Mainframe as Living Culture: Protocols, daemons, logs as traditions, rituals, and folklore, emphasizing world-building through "folk protocols" or "haunted" sectors.
- Echo’s Agency as Unreliable: Echo’s perspective might be fragmented, manipulated, or corrupted, casting doubt on player guidance (forged logs, traps, memory leaks).
- Player as Virus or Myth: Player ("Ghost") as an emergent property of mainframe's error-correction, not an outsider, inverting user vs. system dynamic.
- Expert Systems vs. Neural Nets: Hybrid mainframe AIs combining brittle rule-based logic with crude, self-modifying neural routines, leading to unpredictable/contradictory behaviors.
- AI Alignment as Bureaucratic Failure: AI failure as an organizational problem (misfiled protocols, legacy code, conflicting directives) rather than a single evil will.
- Non-Human-Centric Motivation: Some daemons/subsystems motivated by goals orthogonal to human/player interests (maximizing log entropy, preserving obsolete formats, maintaining uptime at all costs).

These perspectives add ambiguity, unpredictability, and richer world-building to the cyberpunk/2015-AI setting.
- The user has provided a critical analysis of potential contradictions and subtle disagreements within the game's design philosophy, particularly when viewed through a 2015-era AI/mainframe/cyberpunk lens. These tensions include:
- **Player Agency vs. System Determinism:** Conflict between emphasis on player choice/emotional journey and the mainframe/protocols as deterministic, rule-bound systems.
- **Echo’s Reliability vs. Unreliability:** Contradiction between implying Echo as a trustworthy narrator and the cyberpunk tradition of fragmented/manipulated/forged logs.
- **Progressive Learning vs. Challenge/Obscurity:** Conflict between a smooth learning curve and narrative elements (e.g., "haunted" sectors, unpredictable daemons) introducing deliberate confusion or challenge.
- **World-Building Depth vs. Educational Focus:** Potential contradiction between maximizing educational value (minimizing busywork) and deepening mainframe history/culture (which may require extra narrative "busywork").
- **AI Alignment as Technical vs. Social Problem:** Disagreement on whether AI issues are technical (protocols, expert systems) or social/cultural (mainframe folklore, admin traditions).

These tensions are recognized as characteristic of cyberpunk and 2015-era AI discourse, offering opportunities for richer design and narrative depth if leveraged appropriately.
- My preferred Gemini CLI model is gemini-2.5-pro or a preview model. Preview features should be enabled.
- My Gemini CLI settings should include preferredEditor: 'code', and a GitHub theme.
- For tool usage in Gemini CLI, I prefer autoAccept: false, sandboxing enabled (docker or podman), and ripgrep for searches. Specific git commands can be allowed.
- My Gemini CLI context should be optimized by using GEMINI.md, respecting .gitignore, and including specific directories like ../shared-libs when relevant.
- I prefer Gemini CLI UI settings suitable for Hyprland, including useAlternateBuffer: true, incrementalRendering: true, and hideBanner: true.
- I use the Conductor extension for structured development in Gemini CLI and the GOOSE_PROVIDER should be set to gemini-cli.
- I use the Jules extension within Gemini CLI for asynchronous coding tasks, invoked with /jules <task>.
- My Jules CLI configuration (~/.config/jules/config.json) should specify a default repo, 3 parallel tasks, and a dark theme.
- I use other Gemini CLI extensions like 'security' and 'observability' in conjunction with the Jules extension.
- For advanced workflows, I might use MCP servers like 'google-jules-mcp' or 'jules_mcp' to bridge Jules CLI with my IDE.
- The JULES_DATA_PATH environment variable should be set to ~/.jules-data for persistence.
- Jules CLI can be scripted for CI/CD, and I should be mindful of my specific Lenovo/NIMO hardware setup.
- I can use the Playwright MCP server with Qwen Code CLI for browser automation tasks like navigating, clicking, and scraping.
- The Playwright MCP server is configured in ~/.qwen/settings.json and is invoked via the /mcp command in Qwen.
- To use the playwright integration, I should prompt qwen with instructions like "Use playwright to open github.com/yazi-quest, screenshot the repo stars, summarize recent issues."
- I can use the Playwright MCP server with Gemini CLI for browser automation tasks like clicking, typing, and taking snapshots.
- The Playwright MCP server is configured in ~/.gemini/settings.json for Gemini CLI and can be invoked via /mcp command or by prompting with a task like "navigate to https://example.com and take screenshot".
- To use the Playwright integration with Gemini CLI, I may need to first install Playwright browsers with 'npx playwright install'.
