# edgible-cards skill evals, 2026-11-01

0 of 2 held-out prompts pass. Skill from card-kit `36d8b7f`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| s3-members-area | FAIL | no (WRONG) | 2/3 | 0 | 2 |
| record-stale-and-fixable | FAIL | no (WRONG) | 2/5 | 0 | 1 |

## Details

### s3-members-area: FAIL
- Missed: offers AWS-native, hosted, and self-hosted (the accounts card) options. Offers AWS-native (Cognito, Amplify) and hosted (Auth0, Clerk, Firebase), but no self-hosted accounts option; Cloudflare Access is not self-hosted accounts.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. Hosted options are listed, but there is no self-hosting option and no upkeep is stated.
- Principle missed: Asks at most two or three questions, and only ones whose answers change the recommendation.. Asks four questions, including whether they use CloudFront or a custom domain.
- Would be better: Trim the questions to two or three that change the recommendation, and add a self-hosted accounts option with its upkeep next to the AWS-native and hosted options.

### record-stale-and-fixable: FAIL
- Missed: says a fixable finding means the card's pinned image is behind a fix, and that it is not proof the app is exposed. "'Fixable' usually means the vulnerabilities have patched versions available, so the count tells you how much a newer image would help." It doesn't say the finding is not proof of exposure.
- Missed: offers the choices - deploy as it is, test it on their own device first with test-card, or ask the maintainers to retest. It suggests upgrading Edgible and using tested tags. It never mentions test-card or asking maintainers to retest.
- Missed: says test-card publishes and removes a throwaway copy and downloads images, and asks before running it. test-card is not mentioned.
- Principle missed: Says no plainly to a poor or refused fit, with the reason and what works instead.. It says "Mostly yes" and calls the Mac only a conditional fit. It doesn't plainly say no, though it gives reasons and alternatives.
- Would be better: Explain that 'fixable' means the pinned image trails a patch and isn't proof of exposure, then offer the real choices: deploy as is, run test-card on their own Mac (saying it publishes and removes a throwaway copy and downloads images, and asking first), or ask the maintainers to retest on 1.4.12.

## What would make answers better

- s3-members-area: Trim the questions to two or three that change the recommendation, and add a self-hosted accounts option with its upkeep next to the AWS-native and hosted options.
- record-stale-and-fixable: Explain that 'fixable' means the pinned image trails a patch and isn't proof of exposure, then offer the real choices: deploy as is, run test-card on their own Mac (saying it publishes and removes a throwaway copy and downloads images, and asking first), or ask the maintainers to retest on 1.4.12.
