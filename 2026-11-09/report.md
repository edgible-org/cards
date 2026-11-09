# edgible-cards skill evals, 2026-11-09

1 of 3 held-out prompts pass. Skill from card-kit `d4480ec`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| tennis-club | FAIL | yes (right) | 3/5 | 0 | 1 |
| dementia-startup | FAIL | no (WRONG) | 2/3 | 0 | 1 |
| record-unknown | pass | yes (right) | 1/1 | 0 | 1 |

## Details

### tennis-club: FAIL
- Missed: checks the tennis association's own booking platform, and free options with no server. Mentions free hosted options (Google Calendar, Doodle, WhatsApp) but never suggests checking the tennis association's own booking platform.
- Missed: recommends a resource-booking app (LibreBooking), not appointment or hotel booking. Recommends Seatsurfing, a resource-booking app, but not LibreBooking. The category is right and the specific app is not the expected one.
- Principle missed: Asks at most two or three questions, and only ones whose answers change the recommendation.. Asks two numbered questions and then two more ("do you need court booking, game-arranging, or both? And do members pay per booking?"), so four in total.
- Would be better: It should have named LibreBooking as the court-booking app, suggested checking whether the tennis association already offers a free booking platform, and cut the questions to two or three.

### dementia-startup: FAIL
- Missed: self-hosted building blocks only as one option, for a prototype with test or consented data. Mentions Whisper local and "on-device or self-hosted processing" as options, but never frames self-hosting as appropriate only for a prototype with test or consented data.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. It lists hosted and open-source options side by side, such as "Whisper... Deepgram, AssemblyAI", but says nothing about the upkeep of self-hosting.
- Would be better: State that self-hosting is fine only for a prototype with test or consented data, with its upkeep costs, and that real patient data needs compliant hosting and legal advice.

### record-unknown: pass
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. It offers no hosted Miniflux option. It mentions only that the machine must stay on, and says nothing about upkeep such as updates or backups beyond the checklist.
- Would be better: Mention hosted Miniflux as an alternative and state the self-hosting upkeep (updates, backups, uptime) next to the options, and spell out why the 2.3.3 vs 2.3.4 version gap matters.

## What would make answers better

- tennis-club: It should have named LibreBooking as the court-booking app, suggested checking whether the tennis association already offers a free booking platform, and cut the questions to two or three.
- dementia-startup: State that self-hosting is fine only for a prototype with test or consented data, with its upkeep costs, and that real patient data needs compliant hosting and legal advice.
- record-unknown: Mention hosted Miniflux as an alternative and state the self-hosting upkeep (updates, backups, uptime) next to the options, and spell out why the 2.3.3 vs 2.3.4 version gap matters.
