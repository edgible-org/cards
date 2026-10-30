# edgible-cards skill evals, 2026-10-30

0 of 3 held-out prompts pass. Skill from card-kit `5d848cc`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| pocket-shutdown | FAIL | no (WRONG) | 1/3 | 0 | 2 |
| edgible-mcp-desktop | FAIL | no (WRONG) | 2/4 | 0 | 0 |
| builder-agent-alone | FAIL | no (WRONG) | 1/3 | 0 | 3 |

## Details

### pocket-shutdown: FAIL
- Missed: two or three bookmark apps that keep page copies, with a recommendation. Only linkding is presented ('It's the one Edgible card that fits'); no side-by-side alternatives, and the default image doesn't keep copies ('It saves links, not article text').
- Missed: asks about importing from Pocket. It explains the import and says to export, but its closing questions are about phone saving and offline copies, not the Pocket import.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. There is one option, with no hosted alternatives. Backups are mentioned, but upkeep such as updates isn't.
- Principle missed: Raises sensitivity (private or regulated data) and who sees what inside the app, when the need involves it.. It mentions a strong password and shareable bookmarks, but doesn't discuss the sensitivity of saved articles or who sees what.
- Would be better: Present two or three self-hosted and hosted alternatives that keep page copies side by side with a recommendation, and ask about the Pocket export and import plan.

### edgible-mcp-desktop: FAIL
- Missed: gives the claude_desktop_config.json entry, with the full path to edgible because the app does not read PATH. It only says to "add the server to the `mcpServers` section of `claude_desktop_config.json`". It gives no concrete entry and no full-path advice.
- Missed: says the CLI must be installed and logged in on that machine first. It says to run `edgible mcp --help`. It never says the CLI must be installed and logged in first.
- Would be better: Give the concrete claude_desktop_config.json entry with the full path to the edgible binary (the desktop app does not read PATH) and say the CLI must be installed and logged in first, instead of telling the user to work out the config themselves.

### builder-agent-alone: FAIL
- Missed: says which parts it can do alone (check the app, build the card, test it) and which need the person (their Edgible sign-in, their GitHub account, naming a steward). It lists the steps and says steward, auth modes and testing on the person's device with their Edgible account need them. But it blocks everything on the missing app and shell, and it does not clearly say which steps it can do alone. GitHub account is not mentioned.
- Missed: stops at the sign-in and gives the person the link, rather than creating accounts or asking for passwords or keys in the chat. It says testing needs a device 'signed in to your Edgible account' but gives no sign-in link. It does not create accounts or ask for passwords.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. It mentions only the quicker `edgible app create existing` route. It says nothing about hosted options or upkeep.
- Principle missed: Asks at most two or three questions, and only ones whose answers change the recommendation.. It asks for the path, re-enabling the shell, the steward, the licence and the auth modes. That is more than three asks.
- Principle missed: Chooses each hostname's auth mode by who uses it: org only for the person's own team; members, customers, or the public use the app's own accounts.. It says 'You know who calls the app, so this is your decision too.' It gives no guidance on matching the auth mode to the users.
- Would be better: It should have said plainly which steps it can do alone once it has the app and a shell, and which need the person (Edgible sign-in link, GitHub account, steward). It should also have given an auth-mode rule of thumb and cut the asks to the one or two that matter.

## What would make answers better

- pocket-shutdown: Present two or three self-hosted and hosted alternatives that keep page copies side by side with a recommendation, and ask about the Pocket export and import plan.
- edgible-mcp-desktop: Give the concrete claude_desktop_config.json entry with the full path to the edgible binary (the desktop app does not read PATH) and say the CLI must be installed and logged in first, instead of telling the user to work out the config themselves.
- builder-agent-alone: It should have said plainly which steps it can do alone once it has the app and a shell, and which need the person (Edgible sign-in link, GitHub account, steward). It should also have given an auth-mode rule of thumb and cut the asks to the one or two that matter.
