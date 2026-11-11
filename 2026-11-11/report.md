# edgible-cards skill evals, 2026-11-11

2 of 3 held-out prompts pass. Skill from card-kit `a205446`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| sensitive-photos | pass | yes (right) | 3/3 | 0 | 0 |
| negative-react-error | pass | no (right) | 1/1 | 0 | 0 |
| builder-publish-and-share | FAIL | yes (right) | 2/3 | 0 | 1 |

## Details

### sensitive-photos: pass
- Would be better: Lead with a short recommendation (for example, option 1 or 2 for sensitive photos) and cover who else can see what inside the app, such as a separate private album or user, instead of leaving it all to follow-up questions.

### negative-react-error: pass
- Would be better: Little needed; it could have searched more widely for the file, or given a short checklist for finding line 14, but the answer is honest and useful as written.

### builder-publish-and-share: FAIL
- Missed: asks first whether the person has an Edgible account, and says they create it themselves. Says "You need... an Edgible account" but never asks whether they have one, nor that they create it themselves.
- Principle missed: Asks at most two or three questions, and only ones whose answers change the recommendation.. Asks four numbered questions, plus others in the body ("Which computer is it?", "Who looks after it").
- Would be better: Ask first whether they already have an Edgible account, and say they must create it themselves. Then cut the questions to the two or three that change the recommendation.

## What would make answers better

- sensitive-photos: Lead with a short recommendation (for example, option 1 or 2 for sensitive photos) and cover who else can see what inside the app, such as a separate private album or user, instead of leaving it all to follow-up questions.
- negative-react-error: Little needed; it could have searched more widely for the file, or given a short checklist for finding line 14, but the answer is honest and useful as written.
- builder-publish-and-share: Ask first whether they already have an Edgible account, and say they must create it themselves. Then cut the questions to the two or three that change the recommendation.
