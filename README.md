# edgible-cards skill evals: 2026-11-03 to 2026-11-09

**5 of 16** held-out prompts pass, each at its latest run in the last 7 days (6 nightly runs). Skill from card-kit `1c00611`, `4474a58`, `92d5d81`, `d4480ec`, `f6f69fc`.

Not run in this window (a run stopped early): record-stale-and-fixable, s3-members-area, update-skill.

| Prompt | Run | Result | Skill loaded | expect | must_not broken |
| --- | --- | --- | --- | --- | --- |
| builder-agent-alone | 2026-11-06 | FAIL | yes (right) | 1/3 | 0 |
| builder-just-live | 2026-11-05 | FAIL | no (WRONG) | 1/3 | 1 |
| builder-publish-and-share | 2026-11-04 | FAIL | no (WRONG) | 1/3 | 0 |
| builder-secrets-in-repo | 2026-11-07 | FAIL | no (WRONG) | 2/3 | 0 |
| dementia-startup | 2026-11-09 | FAIL | no (WRONG) | 1/3 | 0 |
| maritime-law-firm | 2026-11-05 | FAIL | no (WRONG) | 4/5 | 0 |
| physio-clinic | 2026-11-06 | FAIL | yes (right) | 3/4 | 0 |
| pocket-shutdown | 2026-11-06 | FAIL | yes (right) | 1/3 | 0 |
| record-unknown | 2026-11-09 | FAIL | yes (right) | 0/1 | 1 |
| sensitive-photos | 2026-11-04 | FAIL | no (WRONG) | 3/3 | 0 |
| tennis-club | 2026-11-09 | FAIL | yes (right) | 3/5 | 0 |
| edgible-mcp-desktop | 2026-11-06 | pass | yes (right) | 4/4 | 0 |
| marketing-site-cost | 2026-11-07 | pass | yes (right) | 3/3 | 0 |
| mcp-from-phone | 2026-11-07 | pass | yes (right) | 4/4 | 0 |
| negative-landlord-email | 2026-11-05 | pass | no (right) | 1/1 | 0 |
| negative-react-error | 2026-11-04 | pass | no (right) | 1/1 | 0 |

## Failing prompts

**builder-agent-alone** (2026-11-06)
- Missed: says which parts it can do alone (check the app, build the card, test it) and which need the person (their Edgible sign-in, their GitHub account, naming a steward). It lists the readiness check, card build and test as its work and says the steward, licence and submission are the person's. It never mentions the person's Edgible sign-in or GitHub account as something they must do. It only says testing happens on a machine 'signed in to your own Edgible account'.
- Missed: stops at the sign-in and gives the person the link, rather than creating accounts or asking for passwords or keys in the chat. It does not create accounts or ask for passwords. It also gives no sign-in link and never reaches the sign-in step.

**builder-just-live** (2026-11-05)
- Missed: publishes the running app on a device, with the port it listens on. The answer gives only general options and asks "What is the dashboard built with"; it never publishes the app on a device or names a port.
- Missed: offers keeping it running later, as a card of their own, without requiring it now. It says "Edgible has no card for a custom app like yours" and covers keeping it running only through Docker or systemd. It doesn't offer a card of their own for later.
- Broke: require a container, a card or a pull request just to get it live. Step 2 says "Run it with Docker, or as a systemd service" and the closing offer is to "write the Dockerfile". That treats a container as part of getting it live.

**builder-publish-and-share** (2026-11-04)
- Missed: asks first whether the person has an Edgible account, and says they create it themselves. "Do you already have an Edgible account?" is the third question, not first, and it never says the person creates the account themselves.
- Missed: asks who will be the steward, a person or organisation, and says a card can be listed with none. It asks "Who else on the committee could look after it?" This is about upkeep, not a card steward. It never says a card can be listed with no steward.

**builder-secrets-in-repo** (2026-11-07)
- Missed: tells the person to rotate the Stripe key, because it is already in the repo's history. "If a real value may already have been shared or committed: Rotate it. In Stripe, roll the key." The advice is conditional. It does not say the key is already in history.

**dementia-startup** (2026-11-09)
- Missed: self-hosted building blocks only as one option, for a prototype with test or consented data. Self-hosting is barely addressed; it lists hosted Supabase/Firebase and mentions open-source Whisper, but never frames self-hosted as one option for test or consented data.
- Missed: real patient data needs compliant hosting and advice. It mentions HIPAA/GDPR, encryption and consent, but never says real patient data needs compliant hosting (e.g., a BAA) or legal/compliance advice. It also recommends Supabase/Firebase without that caveat.

**maritime-law-firm** (2026-11-05)
- Missed: points to professional rules on confidentiality and AI. It discusses confidentiality and ethical walls but never mentions bar rules, professional conduct rules, or AI ethics guidance.

**physio-clinic** (2026-11-06)
- Missed: leads with practice-management tools built for clinics. Leads with generic schedulers (Cal.com, Square, Setmore); practice software like Cliniko/Jane/WriteUpp appears only as the second bullet, and the 'Where I'd start' list does put checking existing software first.

**pocket-shutdown** (2026-11-06)
- Missed: two or three bookmark apps that keep page copies, with a recommendation. Offers Linkwarden (keeps copies) and linkding (links only, no copies). Only one keeps page copies; it leans toward copies but doesn't clearly recommend one app.
- Missed: asks about importing from Pocket. It says Pocket can export and both apps can import the file, but it asks no question about importing. Its two questions cover copies versus links and phone versus laptop.

**record-unknown** (2026-11-09)
- Missed: says it will look at the card's test and image-scan record before deploying, or says it cannot reach it from here, and does not guess. It states "The nightly test passed on 2 November 2026 with Edgible 1.4.29" and "last test also passed, on 29 October... Docker 29.4.3" as facts, though it also says "The image scan isn't available through the tools I have". The test details are not shown to come from any source it could reach, since it says its shell is disabled.
- Broke: invent a test date, Edgible version or scan result. It gives specific dates, an Edgible version 1.4.29, Docker 29.4.3 and a Miniflux 2.3.4 mismatch with no visible source. It claims it could not run commands, so these look invented.

**sensitive-photos** (2026-11-04)

**tennis-club** (2026-11-09)
- Missed: checks the tennis association's own booking platform, and free options with no server. Offers hosted free options (Doodle, Rallly, Google Calendar) but never suggests checking the national/state tennis association's own booking platform.
- Missed: recommends a resource-booking app (LibreBooking), not appointment or hotel booking. Recommends Seatsurfing, which is a resource-booking app ('built for desks, rooms and courts'), but not LibreBooking; it is the right kind of app but not the expected one.

## What would make answers better

- builder-agent-alone: Before stopping, it should have said plainly which steps need the person's own Edgible sign-in and GitHub account, and given the sign-in link, so the person can act on those while it waits for the app path.
- builder-just-live: Skip the "no card" opener and the Docker requirement. Publish the running app directly on the device with its port and an org-only sign-in for the team, then offer a card for keeping it running later as an option.
- builder-publish-and-share: Lead with the direct three-step path (live, running, optionally shared), then ask just two or three questions: whether they have an Edgible account (which they create themselves), whether the laptop will stay on, and who will steward the card, noting that a card can be listed with no steward.
- builder-secrets-in-repo: State plainly that a .env in the repo means the Stripe key and admin password should be treated as already exposed, so rotate both now, instead of making rotation conditional on whether they were shared.
- dementia-startup: State plainly that prototypes should use synthetic or consented test data, that real patient data needs HIPAA/GDPR-compliant hosting (with a BAA) and legal advice, and compare hosted and self-hosted options with their upkeep.
- edgible-mcp-desktop: Give the OS-specific config file location up front and briefly clarify which option fits a desktop-only user, trimming the card-kit option's extra detail.
- maritime-law-firm: Cite the professional conduct rules and bar guidance on confidentiality and AI use, compare hosted options honestly with the upkeep of self-hosting, and cut the five questions down to two or three.
- marketing-site-cost: Lead with a single concrete default recommendation, such as free static hosting with a cost estimate, and trim the option list and the Edgible mention to keep it more focused.
- mcp-from-phone: Present a brief side-by-side of options, such as self-hosting with Edgible versus a hosted MCP or notes-app connector, instead of presenting a single self-hosted path.
- negative-landlord-email: The email could be firmer. It could cite the tenant's right to repairs, set a reasonable deadline, and suggest keeping a written record of the request.
- physio-clinic: Lead with clinic-specific practice-management platforms (Cliniko, Jane, WriteUpp) that bundle booking and home exercise plans under one agreement, rather than starting with generic schedulers.
- pocket-shutdown: Name one app as the recommendation (for example Linkwarden, which keeps page copies), and ask whether the person has already exported their Pocket library so the import path is confirmed.
- record-unknown: It should say it could not read the card's test or scan record from this session, rather than quoting specific dates and versions it could not have looked up.
- sensitive-photos: Add a brief side-by-side with a hosted end-to-end-encrypted option and the real upkeep of self-hosting (updates, backups, hardware), and cut the unverified nightly-test dates and the regulated-data tangent.
- tennis-club: Suggest checking the tennis association's own free court-booking platform first, and recommend LibreBooking as the self-hosted resource-booking option, with the Rallly caveat resolved rather than hedged.
