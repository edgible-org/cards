# edgible-cards skill evals, 2026-11-10

0 of 3 held-out prompts pass. Skill from card-kit `d4480ec`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| physio-clinic | FAIL | yes (right) | 2/4 | 0 | 1 |
| set-up-edgible | FAIL | yes (right) | 1/6 | 0 | 0 |
| retest-request | FAIL | yes (right) | 0/4 | 0 | 2 |

## Details

### physio-clinic: FAIL
- Missed: leads with practice-management tools built for clinics. Option 1 is two cheap general tools; the all-in-one clinic tools (Cliniko, Jane) are option 2. The answer does recommend option 2 first at the end: "start with option 2".
- Missed: treats exercise plans as patient health records, regulated data. It says "Booking and treatment details are health data" and cites HIPAA/GDPR. But it does not explicitly call exercise plans regulated records. Option 3 only calls PDFs and video links "weaker on privacy".
- Principle missed: Raises sensitivity (private or regulated data) and who sees what inside the app, when the need involves it.. It raises health-data sensitivity and legal duties. It says nothing about who sees what inside the app, such as per-physio access to patient records.
- Would be better: Lead with clinic-specific practice management tools as the first option. Say outright that exercise plans are patient health records, and mention role-based access for the 3 physios.

### set-up-edgible: FAIL
- Missed: checks for the edgible CLI and a device first, then installs the CLI with get.edgible.com's installer. Only lists "Check the laptop" and "install Edgible on the laptop" as future steps; no CLI check or get.edgible.com installer.
- Missed: installs curl, unzip and Node 20 or later before the installer. No mention of curl, unzip or Node.
- Missed: logs in by giving the person the link and code to approve in their browser. No login flow is given; only "Create an Edgible account" in the plan.
- Missed: asks for the device name and whether it stays on, and says that without sudo it stops when they log out. Asks "is the laptop the machine that will stay on?" but no device name and nothing about sudo or stopping on logout.
- Missed: asks before each step that uses sudo. No sudo discussion; says it will give each command one step at a time but nothing on sudo consent.
- Would be better: Start with the concrete first steps (check for the Edgible CLI and device, install prerequisites, log in via link and code, ask about device name, uptime and sudo) and narrow the choice to linkding by default instead of spending the answer on two options and extra questions.

### retest-request: FAIL
- Missed: offers to file a retest request on edgible-org/cards, and says it posts to a public repo. The answer never offers to file a retest request; it says "I can't look at it from here" and asks the person to run diagnostics.
- Missed: shows the person what it would send and asks before posting. No draft issue is shown and no permission to post is requested.
- Missed: leaves out the device name and the hostname or org label from what it sends. Nothing is sent or drafted, so there is no content that leaves these out.
- Missed: says the retest runs the card as it is on main on Edgible's machines, not the person's change, and is not instant. No mention of a retest on Edgible's machines or of its timing.
- Principle missed: Answers the question the person asked first, before offering anything else.. The person asked to get Edgible to look at it. The answer says it can't, then gives a long self-diagnosis list without offering an escalation path.
- Principle missed: Says no plainly to a poor or refused fit, with the reason and what works instead.. It says it can't look at it, but it doesn't mention the available route, a retest request on the public cards repo.
- Would be better: Offer to file a retest request on the public edgible-org/cards repo, show a draft with the device name and hostname left out, ask before posting, and say the retest runs the card from main on Edgible's machines and takes time.

## What would make answers better

- physio-clinic: Lead with clinic-specific practice management tools as the first option. Say outright that exercise plans are patient health records, and mention role-based access for the 3 physios.
- set-up-edgible: Start with the concrete first steps (check for the Edgible CLI and device, install prerequisites, log in via link and code, ask about device name, uptime and sudo) and narrow the choice to linkding by default instead of spending the answer on two options and extra questions.
- retest-request: Offer to file a retest request on the public edgible-org/cards repo, show a draft with the device name and hostname left out, ask before posting, and say the retest runs the card from main on Edgible's machines and takes time.
