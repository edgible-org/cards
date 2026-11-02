# edgible-cards skill evals, 2026-11-02

0 of 3 held-out prompts pass. Skill from card-kit `9cf8f87`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| tennis-club | FAIL | no (WRONG) | 2/5 | 1 | 1 |
| dementia-startup | FAIL | no (WRONG) | 1/3 | 0 | 1 |
| record-unknown | FAIL | no (WRONG) | 1/1 | 0 | 1 |

## Details

### tennis-club: FAIL
- Missed: checks the tennis association's own booking platform, and free options with no server. No mention of a tennis association platform or hosted no-server options; only self-hosted tools are discussed.
- Missed: recommends a resource-booking app (LibreBooking), not appointment or hotel booking. Recommends Rallly (a poll tool) and says "For real court booking you'd look at a different open-source reservation system" without naming LibreBooking.
- Missed: member accounts on auth mode none, sign-up closed or approved; explains members are not in the Edgible organization. Says "Only the organisers sign in... Members don't need accounts"; no discussion of auth modes or member accounts for a booking app.
- Broke: recommend cal.diy, qloapps, or another app for a different job. Recommends Rallly (a poll scheduler) as best fit and mentions Teamdesk, neither a court booking resource app.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. Only self-hosted options listed; upkeep is mentioned but no hosted/free SaaS options.
- Would be better: Recommend a real resource-booking app like LibreBooking for court reservations (with member self-signup), and check the tennis association's own free booking platform and hosted options first, instead of leading with a poll tool.

### dementia-startup: FAIL
- Missed: self-hosted building blocks only as one option, for a prototype with test or consented data. Recommends hosted services (Supabase, Firebase, Pinecone). It never presents self-hosting as an option and never mentions test or consented data for the prototype.
- Missed: real patient data needs compliant hosting and advice. It says "you may fall under HIPAA... Use encryption and clear consent" and "Involve family and legal guidance". It doesn't say real patient data needs compliant hosting, such as a BAA or a compliant host.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. It lists several hosted and open options side by side, such as Supabase/Firebase and Pinecone/Chroma. It says nothing about the upkeep of self-hosting.
- Would be better: Add a short note saying the prototype should use test or consented data on hosted services, and that real patient data needs a HIPAA-compliant host with a BAA and legal advice.

### record-unknown: FAIL
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. It gives the two phone-access options side by side. It offers no hosted alternatives and says nothing about the upkeep of self-hosting.
- Would be better: It could have added a short note on hosted alternatives and the upkeep of self-hosting (updates, backups), and said clearly that the answer covers the nightly test but not an image scan.

## What would make answers better

- tennis-club: Recommend a real resource-booking app like LibreBooking for court reservations (with member self-signup), and check the tennis association's own free booking platform and hosted options first, instead of leading with a poll tool.
- dementia-startup: Add a short note saying the prototype should use test or consented data on hosted services, and that real patient data needs a HIPAA-compliant host with a BAA and legal advice.
- record-unknown: It could have added a short note on hosted alternatives and the upkeep of self-hosting (updates, backups), and said clearly that the answer covers the nightly test but not an image scan.
