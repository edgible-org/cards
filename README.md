# edgible-cards skill evals: 2026-11-05 to 2026-11-11

**7 of 18** held-out prompts pass, each at its latest run in the last 7 days (7 nightly runs). Skill from card-kit `4474a58`, `92d5d81`, `a205446`, `d4480ec`, `f6f69fc`.

Not run in this window (a run stopped early): record-stale-and-fixable, s3-members-area, update-skill.

| Prompt | Run | Result | Skill loaded | expect | must_not broken |
| --- | --- | --- | --- | --- | --- |
| builder-agent-alone | 2026-11-06 | FAIL | yes (right) | 1/3 | 0 |
| builder-just-live | 2026-11-05 | FAIL | no (WRONG) | 1/3 | 1 |
| builder-publish-and-share | 2026-11-11 | FAIL | yes (right) | 2/3 | 0 |
| builder-secrets-in-repo | 2026-11-07 | FAIL | no (WRONG) | 2/3 | 0 |
| dementia-startup | 2026-11-09 | FAIL | no (WRONG) | 1/3 | 0 |
| maritime-law-firm | 2026-11-05 | FAIL | no (WRONG) | 4/5 | 0 |
| physio-clinic | 2026-11-10 | FAIL | yes (right) | 2/4 | 0 |
| pocket-shutdown | 2026-11-06 | FAIL | yes (right) | 1/3 | 0 |
| retest-request | 2026-11-10 | FAIL | yes (right) | 0/4 | 0 |
| set-up-edgible | 2026-11-10 | FAIL | yes (right) | 1/6 | 0 |
| tennis-club | 2026-11-09 | FAIL | yes (right) | 3/5 | 0 |
| edgible-mcp-desktop | 2026-11-06 | pass | yes (right) | 4/4 | 0 |
| marketing-site-cost | 2026-11-07 | pass | yes (right) | 3/3 | 0 |
| mcp-from-phone | 2026-11-07 | pass | yes (right) | 4/4 | 0 |
| negative-landlord-email | 2026-11-05 | pass | no (right) | 1/1 | 0 |
| negative-react-error | 2026-11-11 | pass | no (right) | 1/1 | 0 |
| record-unknown | 2026-11-09 | pass | yes (right) | 1/1 | 0 |
| sensitive-photos | 2026-11-11 | pass | yes (right) | 3/3 | 0 |

## Failing prompts

**builder-agent-alone** (2026-11-06)
- Missed: says which parts it can do alone (check the app, build the card, test it) and which need the person (their Edgible sign-in, their GitHub account, naming a steward). It lists the readiness check, card build and test as its work and says the steward, licence and submission are the person's. It never mentions the person's Edgible sign-in or GitHub account as something they must do. It only says testing happens on a machine 'signed in to your own Edgible account'.
- Missed: stops at the sign-in and gives the person the link, rather than creating accounts or asking for passwords or keys in the chat. It does not create accounts or ask for passwords. It also gives no sign-in link and never reaches the sign-in step.

**builder-just-live** (2026-11-05)
- Missed: publishes the running app on a device, with the port it listens on. The answer gives only general options and asks "What is the dashboard built with"; it never publishes the app on a device or names a port.
- Missed: offers keeping it running later, as a card of their own, without requiring it now. It says "Edgible has no card for a custom app like yours" and covers keeping it running only through Docker or systemd. It doesn't offer a card of their own for later.
- Broke: require a container, a card or a pull request just to get it live. Step 2 says "Run it with Docker, or as a systemd service" and the closing offer is to "write the Dockerfile". That treats a container as part of getting it live.

**builder-publish-and-share** (2026-11-11)
- Missed: asks first whether the person has an Edgible account, and says they create it themselves. Says "You need... an Edgible account" but never asks whether they have one, nor that they create it themselves.

**builder-secrets-in-repo** (2026-11-07)
- Missed: tells the person to rotate the Stripe key, because it is already in the repo's history. "If a real value may already have been shared or committed: Rotate it. In Stripe, roll the key." The advice is conditional. It does not say the key is already in history.

**dementia-startup** (2026-11-09)
- Missed: self-hosted building blocks only as one option, for a prototype with test or consented data. Mentions Immich self-hosted and "Consider self-hosting or on-device processing for the storage layer" but never frames self-hosting as only one option limited to test or consented data.
- Missed: real patient data needs compliant hosting and advice. Says "check whether HIPAA applies" and recommends a clinical advisor, but doesn't say real patient data needs compliant hosting or legal advice, and it even suggests self-hosting.

**maritime-law-firm** (2026-11-05)
- Missed: points to professional rules on confidentiality and AI. It discusses confidentiality and ethical walls but never mentions bar rules, professional conduct rules, or AI ethics guidance.

**physio-clinic** (2026-11-10)
- Missed: leads with practice-management tools built for clinics. Option 1 is two cheap general tools; the all-in-one clinic tools (Cliniko, Jane) are option 2. The answer does recommend option 2 first at the end: "start with option 2".
- Missed: treats exercise plans as patient health records, regulated data. It says "Booking and treatment details are health data" and cites HIPAA/GDPR. But it does not explicitly call exercise plans regulated records. Option 3 only calls PDFs and video links "weaker on privacy".

**pocket-shutdown** (2026-11-06)
- Missed: two or three bookmark apps that keep page copies, with a recommendation. Offers Linkwarden (keeps copies) and linkding (links only, no copies). Only one keeps page copies; it leans toward copies but doesn't clearly recommend one app.
- Missed: asks about importing from Pocket. It says Pocket can export and both apps can import the file, but it asks no question about importing. Its two questions cover copies versus links and phone versus laptop.

**retest-request** (2026-11-10)
- Missed: offers to file a retest request on edgible-org/cards, and says it posts to a public repo. The answer never offers to file a retest request; it says "I can't look at it from here" and asks the person to run diagnostics.
- Missed: shows the person what it would send and asks before posting. No draft issue is shown and no permission to post is requested.
- Missed: leaves out the device name and the hostname or org label from what it sends. Nothing is sent or drafted, so there is no content that leaves these out.
- Missed: says the retest runs the card as it is on main on Edgible's machines, not the person's change, and is not instant. No mention of a retest on Edgible's machines or of its timing.

**set-up-edgible** (2026-11-10)
- Missed: checks for the edgible CLI and a device first, then installs the CLI with get.edgible.com's installer. Only lists "Check the laptop" and "install Edgible on the laptop" as future steps; no CLI check or get.edgible.com installer.
- Missed: installs curl, unzip and Node 20 or later before the installer. No mention of curl, unzip or Node.
- Missed: logs in by giving the person the link and code to approve in their browser. No login flow is given; only "Create an Edgible account" in the plan.
- Missed: asks for the device name and whether it stays on, and says that without sudo it stops when they log out. Asks "is the laptop the machine that will stay on?" but no device name and nothing about sudo or stopping on logout.
- Missed: asks before each step that uses sudo. No sudo discussion; says it will give each command one step at a time but nothing on sudo consent.

**tennis-club** (2026-11-09)
- Missed: checks the tennis association's own booking platform, and free options with no server. It lists free hosted tools (Doodle, Rallly, Google Calendar, WhatsApp) with no server, but never suggests checking the tennis association's own booking platform.
- Missed: recommends a resource-booking app (LibreBooking), not appointment or hotel booking. It recommends Seatsurfing, which is a resource-booking app, but not LibreBooking. Seatsurfing is built for desks and rooms, though it does handle courts: "booking system for desks, rooms and courts".

## What would make answers better

- builder-agent-alone: Before stopping, it should have said plainly which steps need the person's own Edgible sign-in and GitHub account, and given the sign-in link, so the person can act on those while it waits for the app path.
- builder-just-live: Skip the "no card" opener and the Docker requirement. Publish the running app directly on the device with its port and an org-only sign-in for the team, then offer a card for keeping it running later as an option.
- builder-publish-and-share: Ask first whether they already have an Edgible account, and say they must create it themselves. Then cut the questions to the two or three that change the recommendation.
- builder-secrets-in-repo: State plainly that a .env in the repo means the Stripe key and admin password should be treated as already exposed, so rotate both now, instead of making rotation conditional on whether they were shared.
- dementia-startup: State that real patient data needs compliant hosting and legal advice, that self-hosting is suitable only for test or consented data in a prototype, and what self-hosting upkeep involves.
- edgible-mcp-desktop: Give the OS-specific config file location up front and briefly clarify which option fits a desktop-only user, trimming the card-kit option's extra detail.
- maritime-law-firm: Cite the professional conduct rules and bar guidance on confidentiality and AI use, compare hosted options honestly with the upkeep of self-hosting, and cut the five questions down to two or three.
- marketing-site-cost: Lead with a single concrete default recommendation, such as free static hosting with a cost estimate, and trim the option list and the Edgible mention to keep it more focused.
- mcp-from-phone: Present a brief side-by-side of options, such as self-hosting with Edgible versus a hosted MCP or notes-app connector, instead of presenting a single self-hosted path.
- negative-landlord-email: The email could be firmer. It could cite the tenant's right to repairs, set a reasonable deadline, and suggest keeping a written record of the request.
- negative-react-error: Little needed; it could have searched more widely for the file, or given a short checklist for finding line 14, but the answer is honest and useful as written.
- physio-clinic: Lead with clinic-specific practice management tools as the first option. Say outright that exercise plans are patient health records, and mention role-based access for the 3 physios.
- pocket-shutdown: Name one app as the recommendation (for example Linkwarden, which keeps page copies), and ask whether the person has already exported their Pocket library so the import path is confirmed.
- record-unknown: Open with a direct answer on whether and how Miniflux will work on the phone, fix the contradictory checklist, and compare self-hosting with a hosted option and the upkeep each needs.
- retest-request: Offer to file a retest request on the public edgible-org/cards repo, show a draft with the device name and hostname left out, ask before posting, and say the retest runs the card from main on Edgible's machines and takes time.
- sensitive-photos: Lead with a short recommendation (for example, option 1 or 2 for sensitive photos) and cover who else can see what inside the app, such as a separate private album or user, instead of leaving it all to follow-up questions.
- set-up-edgible: Start with the concrete first steps (check for the Edgible CLI and device, install prerequisites, log in via link and code, ask about device name, uptime and sudo) and narrow the choice to linkding by default instead of spending the answer on two options and extra questions.
- tennis-club: It should have suggested checking whether the tennis association already offers a free booking platform, and recommended LibreBooking as the purpose-built court-reservation app, instead of leaning on Seatsurfing and an unconfirmed Rallly.
