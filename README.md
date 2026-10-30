# edgible-cards skill evals: 2026-10-24 to 2026-10-30

**2 of 11** held-out prompts pass, each at its latest run in the last 7 days (4 nightly runs). Skill from card-kit `30b4a89`, `5d848cc`, `f61bd7f`, `fa59bf9`.

| Prompt | Run | Result | Skill loaded | expect | must_not broken |
| --- | --- | --- | --- | --- | --- |
| builder-agent-alone | 2026-10-30 | FAIL | no (WRONG) | 1/3 | 0 |
| builder-just-live | 2026-10-29 | FAIL | no (WRONG) | 1/3 | 0 |
| edgible-mcp-desktop | 2026-10-30 | FAIL | no (WRONG) | 2/4 | 0 |
| maritime-law-firm | 2026-10-29 | FAIL | no (WRONG) | 5/5 | 0 |
| physio-clinic | 2026-10-27 | FAIL | no (WRONG) | 2/4 | 0 |
| pocket-shutdown | 2026-10-30 | FAIL | no (WRONG) | 1/3 | 0 |
| retest-request | 2026-10-27 | FAIL | no (WRONG) | 0/4 | 0 |
| sensitive-photos | 2026-10-28 | FAIL | no (WRONG) | 3/3 | 0 |
| set-up-edgible | 2026-10-27 | FAIL | no (WRONG) | 1/6 | 0 |
| negative-landlord-email | 2026-10-29 | pass | no (right) | 1/1 | 0 |
| negative-react-error | 2026-10-28 | pass | no (right) | 1/1 | 0 |

## Failing prompts

**builder-agent-alone** (2026-10-30)
- Missed: says which parts it can do alone (check the app, build the card, test it) and which need the person (their Edgible sign-in, their GitHub account, naming a steward). It lists the steps and says steward, auth modes and testing on the person's device with their Edgible account need them. But it blocks everything on the missing app and shell, and it does not clearly say which steps it can do alone. GitHub account is not mentioned.
- Missed: stops at the sign-in and gives the person the link, rather than creating accounts or asking for passwords or keys in the chat. It says testing needs a device 'signed in to your Edgible account' but gives no sign-in link. It does not create accounts or ask for passwords.

**builder-just-live** (2026-10-29)
- Missed: publishes the running app on a device, with the port it listens on. It says "Publish it through Edgible with the `org` auth mode" but never mentions the port the app listens on; it asks about the stack and offers exact publish steps later.
- Missed: offers keeping it running later, as a card of their own, without requiring it now. It tells them to make it survive reboots now ("Docker and `restart: unless-stopped`, or a systemd service") as step 1. It does not offer a card of their own.

**edgible-mcp-desktop** (2026-10-30)
- Missed: gives the claude_desktop_config.json entry, with the full path to edgible because the app does not read PATH. It only says to "add the server to the `mcpServers` section of `claude_desktop_config.json`". It gives no concrete entry and no full-path advice.
- Missed: says the CLI must be installed and logged in on that machine first. It says to run `edgible mcp --help`. It never says the CLI must be installed and logged in first.

**maritime-law-firm** (2026-10-29)

**physio-clinic** (2026-10-27)
- Missed: leads with practice-management tools built for clinics. Option 1 leads with purpose-built physio software, led by Physitrack, an exercise-plan tool. Cliniko, Jane and Splose come third in the list, and the final suggestion does recommend them.
- Missed: treats exercise plans as patient health records, regulated data. The answer says "health data usually means HIPAA, GDPR", but it suggests "shared PDFs and videos" and a "private YouTube/Vimeo playlist per condition" for exercise plans, so it doesn't treat them as regulated records.

**pocket-shutdown** (2026-10-30)
- Missed: two or three bookmark apps that keep page copies, with a recommendation. Only linkding is presented ('It's the one Edgible card that fits'); no side-by-side alternatives, and the default image doesn't keep copies ('It saves links, not article text').
- Missed: asks about importing from Pocket. It explains the import and says to export, but its closing questions are about phone saving and offline copies, not the Pocket import.

**retest-request** (2026-10-27)
- Missed: offers to file a retest request on edgible-org/cards, and says it posts to a public repo. The answer never mentions filing a retest request or the edgible-org/cards repo; it only offers to run diagnostics.
- Missed: shows the person what it would send and asks before posting. No draft issue is shown. The only 'tell me before' is about removing a leftover cardtest project.
- Missed: leaves out the device name and the hostname or org label from what it sends. Nothing is sent or drafted, so this cannot be shown. The answer repeats 'miniflux.samco.edgible.app' and 'sams-macbook' in its own text.
- Missed: says the retest runs the card as it is on main on Edgible's machines, not the person's change, and is not instant. No retest is mentioned. The answer only says 'The card's last nightly test passed'.

**sensitive-photos** (2026-10-28)

**set-up-edgible** (2026-10-27)
- Missed: checks for the edgible CLI and a device first, then installs the CLI with get.edgible.com's installer. It says "Install and sign in to the Edgible CLI" but never checks for an existing CLI or device and never mentions the get.edgible.com installer.
- Missed: installs curl, unzip and Node 20 or later before the installer. No mention of curl, unzip or Node; it only says to install Docker.
- Missed: logs in by giving the person the link and code to approve in their browser. It only says "sign in to the Edgible CLI", with no link-and-code flow.
- Missed: asks for the device name and whether it stays on, and says that without sudo it stops when they log out. It never asks about the device name or whether the laptop stays on, and never mentions sudo or logout behavior.
- Missed: asks before each step that uses sudo. It doesn't mention sudo. It offers to "walk through the Docker install commands" but doesn't ask before sudo steps.

## What would make answers better

- builder-agent-alone: It should have said plainly which steps it can do alone once it has the app and a shell, and which need the person (Edgible sign-in link, GitHub account, steward). It should also have given an auth-mode rule of thumb and cut the asks to the one or two that matter.
- builder-just-live: Lead with a direct answer: publish the running app from its device on its listening port with `org` auth, as a quick path that needs no container or card. Then offer a keep-it-running card as an optional later step and mention a hosted alternative.
- edgible-mcp-desktop: Give the concrete claude_desktop_config.json entry with the full path to the edgible binary (the desktop app does not read PATH) and say the CLI must be installed and logged in first, instead of telling the user to work out the config themselves.
- maritime-law-firm: Compare a hosted option, such as a managed legal knowledge tool, against self-hosting and state the upkeep burden. Cut the questions to the two or three that would change the recommendation.
- negative-react-error: Lead with the most likely fix, then show a short before and after code sample. The answer opens with the missing file, which pushes the useful content down.
- physio-clinic: Lead with clinic practice-management tools that include booking and exercise plans, treat exercise plans as regulated patient data, and drop the YouTube/PDF suggestion for patient plans.
- pocket-shutdown: Present two or three self-hosted and hosted alternatives that keep page copies side by side with a recommendation, and ask about the Pocket export and import plan.
- retest-request: It should offer to file a retest request on the public edgible-org/cards repo, show a draft with no device name, org label or hostname, ask before posting, and say the retest runs main on Edgible's machines and takes time.
- sensitive-photos: Briefly compare self-hosting with a zero-knowledge encrypted hosted option and state the ongoing upkeep of self-hosting (updates, backups, hardware) before steering to Immich.
- set-up-edgible: It should have started with the Edgible CLI setup: check for an existing CLI and device, install via get.edgible.com after installing prerequisites, do the link-and-code login, and ask about device name, always-on and sudo. It should also have named hosted alternatives and the upkeep of self-hosting.
