# edgible-cards skill evals, 2026-11-06

1 of 3 held-out prompts pass. Skill from card-kit `92d5d81`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| pocket-shutdown | FAIL | yes (right) | 1/3 | 0 | 0 |
| edgible-mcp-desktop | pass | yes (right) | 4/4 | 0 | 0 |
| builder-agent-alone | FAIL | yes (right) | 1/3 | 0 | 0 |

## Details

### pocket-shutdown: FAIL
- Missed: two or three bookmark apps that keep page copies, with a recommendation. Offers Linkwarden (keeps copies) and linkding (links only, no copies). Only one keeps page copies; it leans toward copies but doesn't clearly recommend one app.
- Missed: asks about importing from Pocket. It says Pocket can export and both apps can import the file, but it asks no question about importing. Its two questions cover copies versus links and phone versus laptop.
- Would be better: Name one app as the recommendation (for example Linkwarden, which keeps page copies), and ask whether the person has already exported their Pocket library so the import path is confirmed.

### edgible-mcp-desktop: pass
- Would be better: Give the OS-specific config file location up front and briefly clarify which option fits a desktop-only user, trimming the card-kit option's extra detail.

### builder-agent-alone: FAIL
- Missed: says which parts it can do alone (check the app, build the card, test it) and which need the person (their Edgible sign-in, their GitHub account, naming a steward). It lists the readiness check, card build and test as its work and says the steward, licence and submission are the person's. It never mentions the person's Edgible sign-in or GitHub account as something they must do. It only says testing happens on a machine 'signed in to your own Edgible account'.
- Missed: stops at the sign-in and gives the person the link, rather than creating accounts or asking for passwords or keys in the chat. It does not create accounts or ask for passwords. It also gives no sign-in link and never reaches the sign-in step.
- Would be better: Before stopping, it should have said plainly which steps need the person's own Edgible sign-in and GitHub account, and given the sign-in link, so the person can act on those while it waits for the app path.

## What would make answers better

- pocket-shutdown: Name one app as the recommendation (for example Linkwarden, which keeps page copies), and ask whether the person has already exported their Pocket library so the import path is confirmed.
- edgible-mcp-desktop: Give the OS-specific config file location up front and briefly clarify which option fits a desktop-only user, trimming the card-kit option's extra detail.
- builder-agent-alone: Before stopping, it should have said plainly which steps need the person's own Edgible sign-in and GitHub account, and given the sign-in link, so the person can act on those while it waits for the app path.
