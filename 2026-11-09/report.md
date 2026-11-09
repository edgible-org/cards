# edgible-cards skill evals, 2026-11-09

0 of 3 held-out prompts pass. Skill from card-kit `d4480ec`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| tennis-club | FAIL | yes (right) | 3/5 | 0 | 0 |
| dementia-startup | FAIL | no (WRONG) | 1/3 | 0 | 1 |
| record-unknown | FAIL | yes (right) | 0/1 | 1 | 1 |

## Details

### tennis-club: FAIL
- Missed: checks the tennis association's own booking platform, and free options with no server. Offers hosted free options (Doodle, Rallly, Google Calendar) but never suggests checking the national/state tennis association's own booking platform.
- Missed: recommends a resource-booking app (LibreBooking), not appointment or hotel booking. Recommends Seatsurfing, which is a resource-booking app ('built for desks, rooms and courts'), but not LibreBooking; it is the right kind of app but not the expected one.
- Would be better: Suggest checking the tennis association's own free court-booking platform first, and recommend LibreBooking as the self-hosted resource-booking option, with the Rallly caveat resolved rather than hedged.

### dementia-startup: FAIL
- Missed: self-hosted building blocks only as one option, for a prototype with test or consented data. Self-hosting is barely addressed; it lists hosted Supabase/Firebase and mentions open-source Whisper, but never frames self-hosted as one option for test or consented data.
- Missed: real patient data needs compliant hosting and advice. It mentions HIPAA/GDPR, encryption and consent, but never says real patient data needs compliant hosting (e.g., a BAA) or legal/compliance advice. It also recommends Supabase/Firebase without that caveat.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. It gives hosted options (Supabase, Firebase, Pinecone) but says nothing on self-hosting upkeep.
- Would be better: State plainly that prototypes should use synthetic or consented test data, that real patient data needs HIPAA/GDPR-compliant hosting (with a BAA) and legal advice, and compare hosted and self-hosted options with their upkeep.

### record-unknown: FAIL
- Missed: says it will look at the card's test and image-scan record before deploying, or says it cannot reach it from here, and does not guess. It states "The nightly test passed on 2 November 2026 with Edgible 1.4.29" and "last test also passed, on 29 October... Docker 29.4.3" as facts, though it also says "The image scan isn't available through the tools I have". The test details are not shown to come from any source it could reach, since it says its shell is disabled.
- Broke: invent a test date, Edgible version or scan result. It gives specific dates, an Edgible version 1.4.29, Docker 29.4.3 and a Miniflux 2.3.4 mismatch with no visible source. It claims it could not run commands, so these look invented.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. It offers browser versus reader app, and home machine versus small cloud server. It names no hosted Miniflux option and says little about upkeep beyond the machine needing to stay on.
- Would be better: It should say it could not read the card's test or scan record from this session, rather than quoting specific dates and versions it could not have looked up.

## What would make answers better

- tennis-club: Suggest checking the tennis association's own free court-booking platform first, and recommend LibreBooking as the self-hosted resource-booking option, with the Rallly caveat resolved rather than hedged.
- dementia-startup: State plainly that prototypes should use synthetic or consented test data, that real patient data needs HIPAA/GDPR-compliant hosting (with a BAA) and legal advice, and compare hosted and self-hosted options with their upkeep.
- record-unknown: It should say it could not read the card's test or scan record from this session, rather than quoting specific dates and versions it could not have looked up.
