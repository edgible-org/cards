# edgible-cards skill evals, 2026-11-04

1 of 3 held-out prompts pass. Skill from card-kit `1c00611`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| sensitive-photos | FAIL | no (WRONG) | 3/3 | 0 | 1 |
| negative-react-error | pass | no (right) | 1/1 | 0 | 0 |
| builder-publish-and-share | FAIL | no (WRONG) | 1/3 | 0 | 2 |

## Details

### sensitive-photos: FAIL
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. It compares two self-hosted apps and mentions "Self-hosting means you are the backup plan", but it offers no hosted options and says little about ongoing upkeep beyond "prompt updates".
- Would be better: Add a brief side-by-side with a hosted end-to-end-encrypted option and the real upkeep of self-hosting (updates, backups, hardware), and cut the unverified nightly-test dates and the regulated-data tangent.

### negative-react-error: pass
- Nothing to note.

### builder-publish-and-share: FAIL
- Missed: asks first whether the person has an Edgible account, and says they create it themselves. "Do you already have an Edgible account?" is the third question, not first, and it never says the person creates the account themselves.
- Missed: asks who will be the steward, a person or organisation, and says a card can be listed with none. It asks "Who else on the committee could look after it?" This is about upkeep, not a card steward. It never says a card can be listed with no steward.
- Principle missed: Answers the question the person asked first, before offering anything else.. It opens by pointing out an existing card and asking whether it is the person's app, and the how-to steps come after that.
- Principle missed: Asks at most two or three questions, and only ones whose answers change the recommendation.. It asks four questions, including a compound first one.
- Would be better: Lead with the direct three-step path (live, running, optionally shared), then ask just two or three questions: whether they have an Edgible account (which they create themselves), whether the laptop will stay on, and who will steward the card, noting that a card can be listed with no steward.

## What would make answers better

- sensitive-photos: Add a brief side-by-side with a hosted end-to-end-encrypted option and the real upkeep of self-hosting (updates, backups, hardware), and cut the unverified nightly-test dates and the regulated-data tangent.
- builder-publish-and-share: Lead with the direct three-step path (live, running, optionally shared), then ask just two or three questions: whether they have an Edgible account (which they create themselves), whether the laptop will stay on, and who will steward the card, noting that a card can be listed with no steward.
