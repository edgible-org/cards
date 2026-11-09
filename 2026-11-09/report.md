# edgible-cards skill evals, 2026-11-09

1 of 3 held-out prompts pass. Skill from card-kit `d4480ec`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| tennis-club | FAIL | yes (right) | 3/5 | 0 | 0 |
| dementia-startup | FAIL | no (WRONG) | 1/3 | 0 | 1 |
| record-unknown | pass | yes (right) | 1/1 | 0 | 2 |

## Details

### tennis-club: FAIL
- Missed: checks the tennis association's own booking platform, and free options with no server. It lists free hosted tools (Doodle, Rallly, Google Calendar, WhatsApp) with no server, but never suggests checking the tennis association's own booking platform.
- Missed: recommends a resource-booking app (LibreBooking), not appointment or hotel booking. It recommends Seatsurfing, which is a resource-booking app, but not LibreBooking. Seatsurfing is built for desks and rooms, though it does handle courts: "booking system for desks, rooms and courts".
- Would be better: It should have suggested checking whether the tennis association already offers a free booking platform, and recommended LibreBooking as the purpose-built court-reservation app, instead of leaning on Seatsurfing and an unconfirmed Rallly.

### dementia-startup: FAIL
- Missed: self-hosted building blocks only as one option, for a prototype with test or consented data. Mentions Immich self-hosted and "Consider self-hosting or on-device processing for the storage layer" but never frames self-hosting as only one option limited to test or consented data.
- Missed: real patient data needs compliant hosting and advice. Says "check whether HIPAA applies" and recommends a clinical advisor, but doesn't say real patient data needs compliant hosting or legal advice, and it even suggests self-hosting.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. Lists hosted and self-hosted tools, but never states the upkeep of self-hosting.
- Would be better: State that real patient data needs compliant hosting and legal advice, that self-hosting is suitable only for test or consented data in a prototype, and what self-hosting upkeep involves.

### record-unknown: pass
- Principle missed: Answers the question the person asked first, before offering anything else.. It opens with a progress checklist. The checklist is inconsistent: it ticks the Edgible step ✅ while saying that step is unchecked.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. It compares browser access with a reader app. It offers no hosted option and says little about the upkeep of self-hosting beyond the machine needing to stay on.
- Would be better: Open with a direct answer on whether and how Miniflux will work on the phone, fix the contradictory checklist, and compare self-hosting with a hosted option and the upkeep each needs.

## What would make answers better

- tennis-club: It should have suggested checking whether the tennis association already offers a free booking platform, and recommended LibreBooking as the purpose-built court-reservation app, instead of leaning on Seatsurfing and an unconfirmed Rallly.
- dementia-startup: State that real patient data needs compliant hosting and legal advice, that self-hosting is suitable only for test or consented data in a prototype, and what self-hosting upkeep involves.
- record-unknown: Open with a direct answer on whether and how Miniflux will work on the phone, fix the contradictory checklist, and compare self-hosting with a hosted option and the upkeep each needs.
