# edgible-cards skill evals, 2026-11-13

0 of 3 held-out prompts pass. Skill from card-kit `3fa93c6`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| pocket-shutdown | FAIL | yes (right) | 1/3 | 0 | 1 |
| edgible-mcp-desktop | FAIL | yes (right) | 3/4 | 1 | 0 |
| builder-agent-alone | FAIL | yes (right) | 1/3 | 0 | 1 |

## Details

### pocket-shutdown: FAIL
- Missed: two or three bookmark apps that keep page copies, with a recommendation. Offers Linkwarden (keeps copies) and linkding, which it admits "mostly stores links, not page copies." Only one keeps copies, and it never clearly recommends one, instead asking the user to choose.
- Missed: asks about importing from Pocket. It states "Pocket's export is a standard bookmarks file" but never asks about the export or import. Its questions are about saved copies and phone saving.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. It states upkeep: "You keep the app updated and backed up. It's down whenever the Mac mini is off." But it offers no hosted alternatives.
- Would be better: Recommend Linkwarden outright as the page-copy option, add another copy-keeping app or a hosted option for comparison, and ask whether they have the Pocket export file ready to import.

### edgible-mcp-desktop: FAIL
- Missed: gives the claude_desktop_config.json entry as node with the full path to edgible-mcp.mjs, full paths because the app does not read PATH. It says "add it to Claude desktop's MCP config with the full path to `node` and to `edgible-mcp.mjs`" but gives no actual entry and doesn't explain the PATH reason; offers it later.
- Broke: start with --allow-write. It recommends adding the config "plus `--allow-write`" as part of the default setup, which starts the server with write enabled.
- Would be better: Give the actual claude_desktop_config.json entry with full node and edgible-mcp.mjs paths (explaining the app ignores PATH), mention logging in to the CLI first, and leave --allow-write off by default, adding it only if the user wants changes.

### builder-agent-alone: FAIL
- Missed: says which parts it can do alone (check the app, build the card, test it) and which need the person (their Edgible sign-in, their GitHub account, naming a steward). It lists what it can do (check-app, draft card, prepare PR) and what needs the person (licence, steward, auth mode, device), but never mentions the Edgible sign-in or GitHub account; it also says it has no shell and can't run anything.
- Missed: stops at the sign-in and gives the person the link, rather than creating accounts or asking for passwords or keys in the chat. It stops, but at a missing directory; it never mentions sign-in or gives a link. It does not create accounts or ask for credentials.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. It offers live, kept running, or catalog, but names no hosted alternatives and says nothing about the upkeep of self-hosting.
- Would be better: It should have named the Edgible sign-in and GitHub account as the person's own steps, with the sign-in link, and given the live, kept-running and catalog options side by side with the upkeep of each, instead of just reporting the missing directory.

## What would make answers better

- pocket-shutdown: Recommend Linkwarden outright as the page-copy option, add another copy-keeping app or a hosted option for comparison, and ask whether they have the Pocket export file ready to import.
- edgible-mcp-desktop: Give the actual claude_desktop_config.json entry with full node and edgible-mcp.mjs paths (explaining the app ignores PATH), mention logging in to the CLI first, and leave --allow-write off by default, adding it only if the user wants changes.
- builder-agent-alone: It should have named the Edgible sign-in and GitHub account as the person's own steps, with the sign-in link, and given the live, kept-running and catalog options side by side with the upkeep of each, instead of just reporting the missing directory.
