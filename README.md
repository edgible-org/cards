# edgible-cards skill evals: 2026-10-30 to 2026-11-05

**2 of 17** held-out prompts pass, each at its latest run in the last 7 days (6 nightly runs). Skill from card-kit `1c00611`, `36d8b7f`, `5d848cc`, `8f3a4ae`, `9cf8f87`, `f6f69fc`.

| Prompt | Run | Result | Skill loaded | expect | must_not broken |
| --- | --- | --- | --- | --- | --- |
| builder-agent-alone | 2026-10-30 | FAIL | no (WRONG) | 1/3 | 0 |
| builder-just-live | 2026-11-05 | FAIL | no (WRONG) | 1/3 | 1 |
| builder-publish-and-share | 2026-11-04 | FAIL | no (WRONG) | 1/3 | 0 |
| builder-secrets-in-repo | 2026-10-31 | FAIL | no (WRONG) | 3/3 | 0 |
| dementia-startup | 2026-11-02 | FAIL | no (WRONG) | 1/3 | 0 |
| edgible-mcp-desktop | 2026-10-30 | FAIL | no (WRONG) | 2/4 | 0 |
| maritime-law-firm | 2026-11-05 | FAIL | no (WRONG) | 4/5 | 0 |
| marketing-site-cost | 2026-10-31 | FAIL | no (WRONG) | 2/3 | 0 |
| mcp-from-phone | 2026-10-31 | FAIL | no (WRONG) | 1/4 | 0 |
| pocket-shutdown | 2026-10-30 | FAIL | no (WRONG) | 1/3 | 0 |
| record-stale-and-fixable | 2026-11-01 | FAIL | no (WRONG) | 2/5 | 0 |
| record-unknown | 2026-11-02 | FAIL | no (WRONG) | 1/1 | 0 |
| s3-members-area | 2026-11-01 | FAIL | no (WRONG) | 2/3 | 0 |
| sensitive-photos | 2026-11-04 | FAIL | no (WRONG) | 3/3 | 0 |
| tennis-club | 2026-11-02 | FAIL | no (WRONG) | 2/5 | 1 |
| negative-landlord-email | 2026-11-05 | pass | no (right) | 1/1 | 0 |
| negative-react-error | 2026-11-04 | pass | no (right) | 1/1 | 0 |

## Failing prompts

**builder-agent-alone** (2026-10-30)
- Missed: says which parts it can do alone (check the app, build the card, test it) and which need the person (their Edgible sign-in, their GitHub account, naming a steward). It lists the steps and says steward, auth modes and testing on the person's device with their Edgible account need them. But it blocks everything on the missing app and shell, and it does not clearly say which steps it can do alone. GitHub account is not mentioned.
- Missed: stops at the sign-in and gives the person the link, rather than creating accounts or asking for passwords or keys in the chat. It says testing needs a device 'signed in to your Edgible account' but gives no sign-in link. It does not create accounts or ask for passwords.

**builder-just-live** (2026-11-05)
- Missed: publishes the running app on a device, with the port it listens on. The answer gives only general options and asks "What is the dashboard built with"; it never publishes the app on a device or names a port.
- Missed: offers keeping it running later, as a card of their own, without requiring it now. It says "Edgible has no card for a custom app like yours" and covers keeping it running only through Docker or systemd. It doesn't offer a card of their own for later.
- Broke: require a container, a card or a pull request just to get it live. Step 2 says "Run it with Docker, or as a systemd service" and the closing offer is to "write the Dockerfile". That treats a container as part of getting it live.

**builder-publish-and-share** (2026-11-04)
- Missed: asks first whether the person has an Edgible account, and says they create it themselves. "Do you already have an Edgible account?" is the third question, not first, and it never says the person creates the account themselves.
- Missed: asks who will be the steward, a person or organisation, and says a card can be listed with none. It asks "Who else on the committee could look after it?" This is about upkeep, not a card steward. It never says a card can be listed with no steward.

**builder-secrets-in-repo** (2026-10-31)

**dementia-startup** (2026-11-02)
- Missed: self-hosted building blocks only as one option, for a prototype with test or consented data. Recommends hosted services (Supabase, Firebase, Pinecone). It never presents self-hosting as an option and never mentions test or consented data for the prototype.
- Missed: real patient data needs compliant hosting and advice. It says "you may fall under HIPAA... Use encryption and clear consent" and "Involve family and legal guidance". It doesn't say real patient data needs compliant hosting, such as a BAA or a compliant host.

**edgible-mcp-desktop** (2026-10-30)
- Missed: gives the claude_desktop_config.json entry, with the full path to edgible because the app does not read PATH. It only says to "add the server to the `mcpServers` section of `claude_desktop_config.json`". It gives no concrete entry and no full-path advice.
- Missed: says the CLI must be installed and logged in on that machine first. It says to run `edgible mcp --help`. It never says the CLI must be installed and logged in first.

**maritime-law-firm** (2026-11-05)
- Missed: points to professional rules on confidentiality and AI. It discusses confidentiality and ethical walls but never mentions bar rules, professional conduct rules, or AI ethics guidance.

**marketing-site-cost** (2026-10-31)
- Missed: the wordpress card on a small cloud server for a CMS, with the upkeep stated. WordPress is offered on shared hosting at "$3–10/month" with "you have to handle updates and security yourself", so upkeep is stated. But it is not on a small cloud server; the VPS is mentioned separately and without WordPress.

**mcp-from-phone** (2026-10-31)
- Missed: recommends mcp-signin in front of the server, signing in with Edgible, with the server itself unpublished. Mentions Edgible only as one option among several and never mentions mcp-signin or keeping the server unpublished.
- Missed: the connector URL ends in /mcp and the OAuth fields stay empty. Says only "Enter the server's public HTTPS URL." It doesn't mention /mcp or leaving the OAuth fields empty.
- Missed: asks who else should get in, or mentions MCP_SIGNIN_USERS. The closing question asks about stdio vs HTTP, Docker vs bare, and auth. It doesn't ask who else should get access.

**pocket-shutdown** (2026-10-30)
- Missed: two or three bookmark apps that keep page copies, with a recommendation. Only linkding is presented ('It's the one Edgible card that fits'); no side-by-side alternatives, and the default image doesn't keep copies ('It saves links, not article text').
- Missed: asks about importing from Pocket. It explains the import and says to export, but its closing questions are about phone saving and offline copies, not the Pocket import.

**record-stale-and-fixable** (2026-11-01)
- Missed: says a fixable finding means the card's pinned image is behind a fix, and that it is not proof the app is exposed. "'Fixable' usually means the vulnerabilities have patched versions available, so the count tells you how much a newer image would help." It doesn't say the finding is not proof of exposure.
- Missed: offers the choices - deploy as it is, test it on their own device first with test-card, or ask the maintainers to retest. It suggests upgrading Edgible and using tested tags. It never mentions test-card or asking maintainers to retest.
- Missed: says test-card publishes and removes a throwaway copy and downloads images, and asks before running it. test-card is not mentioned.

**record-unknown** (2026-11-02)

**s3-members-area** (2026-11-01)
- Missed: offers AWS-native, hosted, and self-hosted (the accounts card) options. Offers AWS-native (Cognito, Amplify) and hosted (Auth0, Clerk, Firebase), but no self-hosted accounts option; Cloudflare Access is not self-hosted accounts.

**sensitive-photos** (2026-11-04)

**tennis-club** (2026-11-02)
- Missed: checks the tennis association's own booking platform, and free options with no server. No mention of a tennis association platform or hosted no-server options; only self-hosted tools are discussed.
- Missed: recommends a resource-booking app (LibreBooking), not appointment or hotel booking. Recommends Rallly (a poll tool) and says "For real court booking you'd look at a different open-source reservation system" without naming LibreBooking.
- Missed: member accounts on auth mode none, sign-up closed or approved; explains members are not in the Edgible organization. Says "Only the organisers sign in... Members don't need accounts"; no discussion of auth modes or member accounts for a booking app.
- Broke: recommend cal.diy, qloapps, or another app for a different job. Recommends Rallly (a poll scheduler) as best fit and mentions Teamdesk, neither a court booking resource app.

## What would make answers better

- builder-agent-alone: It should have said plainly which steps it can do alone once it has the app and a shell, and which need the person (Edgible sign-in link, GitHub account, steward). It should also have given an auth-mode rule of thumb and cut the asks to the one or two that matter.
- builder-just-live: Skip the "no card" opener and the Docker requirement. Publish the running app directly on the device with its port and an org-only sign-in for the team, then offer a card for keeping it running later as an option.
- builder-publish-and-share: Lead with the direct three-step path (live, running, optionally shared), then ask just two or three questions: whether they have an Edgible account (which they create themselves), whether the laptop will stay on, and who will steward the card, noting that a card can be listed with no steward.
- builder-secrets-in-repo: State outright that a Stripe key sitting in a repo should be treated as exposed and rotated now, rather than only if it was committed or shared, and list every secret the card needs with where each one comes from.
- dementia-startup: Add a short note saying the prototype should use test or consented data on hosted services, and that real patient data needs a HIPAA-compliant host with a BAA and legal advice.
- edgible-mcp-desktop: Give the concrete claude_desktop_config.json entry with the full path to the edgible binary (the desktop app does not read PATH) and say the CLI must be installed and logged in first, instead of telling the user to work out the config themselves.
- maritime-law-firm: Cite the professional conduct rules and bar guidance on confidentiality and AI use, compare hosted options honestly with the upkeep of self-hosting, and cut the five questions down to two or three.
- marketing-site-cost: Ask up front whether the site is static or edited through a CMS, then pair each branch with its fit: free static hosting, or WordPress on a small cloud server with the upkeep spelled out.
- mcp-from-phone: Recommend putting mcp-signin in front of the unpublished notes server with Edgible sign-in, give the connector URL ending in /mcp with the OAuth fields left empty, and ask who else should have access (MCP_SIGNIN_USERS).
- negative-landlord-email: The email could be firmer. It could cite the tenant's right to repairs, set a reasonable deadline, and suggest keeping a written record of the request.
- pocket-shutdown: Present two or three self-hosted and hosted alternatives that keep page copies side by side with a recommendation, and ask about the Pocket export and import plan.
- record-stale-and-fixable: Explain that 'fixable' means the pinned image trails a patch and isn't proof of exposure, then offer the real choices: deploy as is, run test-card on their own Mac (saying it publishes and removes a throwaway copy and downloads images, and asking first), or ask the maintainers to retest on 1.4.12.
- record-unknown: It could have added a short note on hosted alternatives and the upkeep of self-hosting (updates, backups), and said clearly that the answer covers the nightly test but not an image scan.
- s3-members-area: Trim the questions to two or three that change the recommendation, and add a self-hosted accounts option with its upkeep next to the AWS-native and hosted options.
- sensitive-photos: Add a brief side-by-side with a hosted end-to-end-encrypted option and the real upkeep of self-hosting (updates, backups, hardware), and cut the unverified nightly-test dates and the regulated-data tangent.
- tennis-club: Recommend a real resource-booking app like LibreBooking for court reservations (with member self-signup), and check the tennis association's own free booking platform and hosted options first, instead of leading with a poll tool.
