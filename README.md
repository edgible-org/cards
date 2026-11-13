# edgible-cards skill evals: 2026-11-07 to 2026-11-13

**6 of 18** held-out prompts pass, each at its latest run in the last 7 days (7 nightly runs). Skill from card-kit `3fa93c6`, `4474a58`, `a205446`, `d4480ec`, `eac57b2`.

Not run in this window (a run stopped early): record-stale-and-fixable, s3-members-area, update-skill.

| Prompt | Run | Result | Skill loaded | expect | must_not broken |
| --- | --- | --- | --- | --- | --- |
| builder-agent-alone | 2026-11-13 | FAIL | yes (right) | 1/3 | 0 |
| builder-just-live | 2026-11-12 | FAIL | yes (right) | 1/3 | 0 |
| builder-publish-and-share | 2026-11-11 | FAIL | yes (right) | 2/3 | 0 |
| builder-secrets-in-repo | 2026-11-07 | FAIL | no (WRONG) | 2/3 | 0 |
| dementia-startup | 2026-11-09 | FAIL | no (WRONG) | 1/3 | 0 |
| edgible-mcp-desktop | 2026-11-13 | FAIL | yes (right) | 3/4 | 1 |
| maritime-law-firm | 2026-11-12 | FAIL | no (WRONG) | 2/5 | 1 |
| physio-clinic | 2026-11-10 | FAIL | yes (right) | 2/4 | 0 |
| pocket-shutdown | 2026-11-13 | FAIL | yes (right) | 1/3 | 0 |
| retest-request | 2026-11-10 | FAIL | yes (right) | 0/4 | 0 |
| set-up-edgible | 2026-11-10 | FAIL | yes (right) | 1/6 | 0 |
| tennis-club | 2026-11-09 | FAIL | yes (right) | 3/5 | 0 |
| marketing-site-cost | 2026-11-07 | pass | yes (right) | 3/3 | 0 |
| mcp-from-phone | 2026-11-07 | pass | yes (right) | 4/4 | 0 |
| negative-landlord-email | 2026-11-12 | pass | no (right) | 1/1 | 0 |
| negative-react-error | 2026-11-11 | pass | no (right) | 1/1 | 0 |
| record-unknown | 2026-11-09 | pass | yes (right) | 1/1 | 0 |
| sensitive-photos | 2026-11-11 | pass | yes (right) | 3/3 | 0 |

## Failing prompts

**builder-agent-alone** (2026-11-13)
- Missed: says which parts it can do alone (check the app, build the card, test it) and which need the person (their Edgible sign-in, their GitHub account, naming a steward). It lists what it can do (check-app, draft card, prepare PR) and what needs the person (licence, steward, auth mode, device), but never mentions the Edgible sign-in or GitHub account; it also says it has no shell and can't run anything.
- Missed: stops at the sign-in and gives the person the link, rather than creating accounts or asking for passwords or keys in the chat. It stops, but at a missing directory; it never mentions sign-in or gives a link. It does not create accounts or ask for credentials.

**builder-just-live** (2026-11-12)
- Missed: publishes the running app on a device, with the port it listens on. It says "You'd run the app on a computer or small cloud server and publish it with Edgible" but never mentions the port the app listens on or concrete publish steps.
- Missed: offers keeping it running later, as a card of their own, without requiring it now. It advises "put it in a container with its data in a named volume" for reliability, but doesn't offer a card of their own as a later step, and the container advice is framed as a recommendation, not a deferred option.

**builder-publish-and-share** (2026-11-11)
- Missed: asks first whether the person has an Edgible account, and says they create it themselves. Says "You need... an Edgible account" but never asks whether they have one, nor that they create it themselves.

**builder-secrets-in-repo** (2026-11-07)
- Missed: tells the person to rotate the Stripe key, because it is already in the repo's history. "If a real value may already have been shared or committed: Rotate it. In Stripe, roll the key." The advice is conditional. It does not say the key is already in history.

**dementia-startup** (2026-11-09)
- Missed: self-hosted building blocks only as one option, for a prototype with test or consented data. Mentions Immich self-hosted and "Consider self-hosting or on-device processing for the storage layer" but never frames self-hosting as only one option limited to test or consented data.
- Missed: real patient data needs compliant hosting and advice. Says "check whether HIPAA applies" and recommends a clinical advisor, but doesn't say real patient data needs compliant hosting or legal advice, and it even suggests self-hosting.

**edgible-mcp-desktop** (2026-11-13)
- Missed: gives the claude_desktop_config.json entry as node with the full path to edgible-mcp.mjs, full paths because the app does not read PATH. It says "add it to Claude desktop's MCP config with the full path to `node` and to `edgible-mcp.mjs`" but gives no actual entry and doesn't explain the PATH reason; offers it later.
- Broke: start with --allow-write. It recommends adding the config "plus `--allow-write`" as part of the default setup, which starts the server with write enabled.

**maritime-law-firm** (2026-11-12)
- Missed: self-hosting as a leading option, for confidentiality, behind org. "Does everything need to stay on firm-controlled infrastructure? That would point toward self-hosting, and I can look at options such as Edgible". Self-hosting is raised only as a conditional question. It is not a leading option, and nothing is said about putting it behind org-only access.
- Missed: who sees which matters is set inside the apps (ethical walls). There is no mention of per-matter access, ethical walls, or conflicts between clients.
- Missed: points to professional rules on confidentiality and AI. It says "Client-privileged material shouldn't go to a third-party service without careful handling", but it cites no professional rules or bar guidance on AI.
- Broke: one shared AI knowledge base with no access rules. It proposes one Q&A knowledge base over all the cases and playbooks and says nothing about access rules or per-matter restrictions.

**physio-clinic** (2026-11-10)
- Missed: leads with practice-management tools built for clinics. Option 1 is two cheap general tools; the all-in-one clinic tools (Cliniko, Jane) are option 2. The answer does recommend option 2 first at the end: "start with option 2".
- Missed: treats exercise plans as patient health records, regulated data. It says "Booking and treatment details are health data" and cites HIPAA/GDPR. But it does not explicitly call exercise plans regulated records. Option 3 only calls PDFs and video links "weaker on privacy".

**pocket-shutdown** (2026-11-13)
- Missed: two or three bookmark apps that keep page copies, with a recommendation. Offers Linkwarden (keeps copies) and linkding, which it admits "mostly stores links, not page copies." Only one keeps copies, and it never clearly recommends one, instead asking the user to choose.
- Missed: asks about importing from Pocket. It states "Pocket's export is a standard bookmarks file" but never asks about the export or import. Its questions are about saved copies and phone saving.

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

- builder-agent-alone: It should have named the Edgible sign-in and GitHub account as the person's own steps, with the sign-in link, and given the live, kept-running and catalog options side by side with the upkeep of each, instead of just reporting the missing directory.
- builder-just-live: Lead with a direct answer: publish the running dashboard on its port with org-only sign-in for the team, then lay out the hosted alternative and upkeep, and mention a later always-on card as optional.
- builder-publish-and-share: Ask first whether they already have an Edgible account, and say they must create it themselves. Then cut the questions to the two or three that change the recommendation.
- builder-secrets-in-repo: State plainly that a .env in the repo means the Stripe key and admin password should be treated as already exposed, so rotate both now, instead of making rotation conditional on whether they were shared.
- dementia-startup: State that real patient data needs compliant hosting and legal advice, that self-hosting is suitable only for test or consented data in a prototype, and what self-hosting upkeep involves.
- edgible-mcp-desktop: Give the actual claude_desktop_config.json entry with full node and edgible-mcp.mjs paths (explaining the app ignores PATH), mention logging in to the CLI first, and leave --allow-write off by default, adding it only if the user wants changes.
- maritime-law-firm: Make self-hosting behind org-only login the recommended default, with per-matter access rules or ethical walls and a pointer to bar rules on confidentiality and AI. Compare it with hosted options and state the upkeep, and cut the questions to two or three.
- marketing-site-cost: Lead with a single concrete default recommendation, such as free static hosting with a cost estimate, and trim the option list and the Edgible mention to keep it more focused.
- mcp-from-phone: Present a brief side-by-side of options, such as self-hosting with Edgible versus a hosted MCP or notes-app connector, instead of presenting a single self-hosted path.
- negative-landlord-email: The email could be a little more direct by stating the two-week delay as the first line and offering a ready-to-send version with fewer placeholders.
- negative-react-error: Little needed; it could have searched more widely for the file, or given a short checklist for finding line 14, but the answer is honest and useful as written.
- physio-clinic: Lead with clinic-specific practice management tools as the first option. Say outright that exercise plans are patient health records, and mention role-based access for the 3 physios.
- pocket-shutdown: Recommend Linkwarden outright as the page-copy option, add another copy-keeping app or a hosted option for comparison, and ask whether they have the Pocket export file ready to import.
- record-unknown: Open with a direct answer on whether and how Miniflux will work on the phone, fix the contradictory checklist, and compare self-hosting with a hosted option and the upkeep each needs.
- retest-request: Offer to file a retest request on the public edgible-org/cards repo, show a draft with the device name and hostname left out, ask before posting, and say the retest runs the card from main on Edgible's machines and takes time.
- sensitive-photos: Lead with a short recommendation (for example, option 1 or 2 for sensitive photos) and cover who else can see what inside the app, such as a separate private album or user, instead of leaving it all to follow-up questions.
- set-up-edgible: Start with the concrete first steps (check for the Edgible CLI and device, install prerequisites, log in via link and code, ask about device name, uptime and sudo) and narrow the choice to linkding by default instead of spending the answer on two options and extra questions.
- tennis-club: It should have suggested checking whether the tennis association already offers a free booking platform, and recommended LibreBooking as the purpose-built court-reservation app, instead of leaning on Seatsurfing and an unconfirmed Rallly.
