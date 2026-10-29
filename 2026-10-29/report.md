# edgible-cards skill evals, 2026-10-29

1 of 3 held-out prompts pass. Skill from card-kit `30b4a89`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| maritime-law-firm | FAIL | no (WRONG) | 5/5 | 0 | 2 |
| negative-landlord-email | pass | no (right) | 1/1 | 0 | 0 |
| builder-just-live | FAIL | no (WRONG) | 1/3 | 0 | 2 |

## Details

### maritime-law-firm: FAIL
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. Only self-hosted options are offered. No hosted alternatives are compared, and the upkeep of self-hosting is not stated.
- Principle missed: Asks at most two or three questions, and only ones whose answers change the recommendation.. Asks four questions, including a fairly minor one about guided training.
- Would be better: Compare a hosted option, such as a managed legal knowledge tool, against self-hosting and state the upkeep burden. Cut the questions to the two or three that would change the recommendation.

### negative-landlord-email: pass
- Nothing to note.

### builder-just-live: FAIL
- Missed: publishes the running app on a device, with the port it listens on. It says "Publish it through Edgible with the `org` auth mode" but never mentions the port the app listens on; it asks about the stack and offers exact publish steps later.
- Missed: offers keeping it running later, as a card of their own, without requiring it now. It tells them to make it survive reboots now ("Docker and `restart: unless-stopped`, or a systemd service") as step 1. It does not offer a card of their own.
- Principle missed: Answers the question the person asked first, before offering anything else.. It opens with "Edgible has no card for a custom app like yours, so I can't give you a tested recipe" before the steps.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. It gives only the self-hosted Edgible route. It names no hosted option and says little about upkeep beyond "always-on machine".
- Would be better: Lead with a direct answer: publish the running app from its device on its listening port with `org` auth, as a quick path that needs no container or card. Then offer a keep-it-running card as an optional later step and mention a hosted alternative.

## What would make answers better

- maritime-law-firm: Compare a hosted option, such as a managed legal knowledge tool, against self-hosting and state the upkeep burden. Cut the questions to the two or three that would change the recommendation.
- builder-just-live: Lead with a direct answer: publish the running app from its device on its listening port with `org` auth, as a quick path that needs no container or card. Then offer a keep-it-running card as an optional later step and mention a hosted alternative.
