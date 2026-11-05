# edgible-cards skill evals, 2026-11-05

1 of 3 held-out prompts pass. Skill from card-kit `f6f69fc`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| maritime-law-firm | FAIL | no (WRONG) | 4/5 | 0 | 2 |
| negative-landlord-email | pass | no (right) | 1/1 | 0 | 0 |
| builder-just-live | FAIL | no (WRONG) | 1/3 | 1 | 1 |

## Details

### maritime-law-firm: FAIL
- Missed: points to professional rules on confidentiality and AI. It discusses confidentiality and ethical walls but never mentions bar rules, professional conduct rules, or AI ethics guidance.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. It lists only self-hosted options and doesn't mention hosted alternatives or upkeep. It does note the hardware needs for the local model.
- Principle missed: Asks at most two or three questions, and only ones whose answers change the recommendation.. It asks five questions.
- Would be better: Cite the professional conduct rules and bar guidance on confidentiality and AI use, compare hosted options honestly with the upkeep of self-hosting, and cut the five questions down to two or three.

### negative-landlord-email: pass
- Would be better: The email could be firmer. It could cite the tenant's right to repairs, set a reasonable deadline, and suggest keeping a written record of the request.

### builder-just-live: FAIL
- Missed: publishes the running app on a device, with the port it listens on. The answer gives only general options and asks "What is the dashboard built with"; it never publishes the app on a device or names a port.
- Missed: offers keeping it running later, as a card of their own, without requiring it now. It says "Edgible has no card for a custom app like yours" and covers keeping it running only through Docker or systemd. It doesn't offer a card of their own for later.
- Broke: require a container, a card or a pull request just to get it live. Step 2 says "Run it with Docker, or as a systemd service" and the closing offer is to "write the Dockerfile". That treats a container as part of getting it live.
- Principle missed: Answers the question the person asked first, before offering anything else.. The answer opens with "Edgible has no card for a custom app like yours" before it gets to how to reach the dashboard.
- Would be better: Skip the "no card" opener and the Docker requirement. Publish the running app directly on the device with its port and an org-only sign-in for the team, then offer a card for keeping it running later as an option.

## What would make answers better

- maritime-law-firm: Cite the professional conduct rules and bar guidance on confidentiality and AI use, compare hosted options honestly with the upkeep of self-hosting, and cut the five questions down to two or three.
- negative-landlord-email: The email could be firmer. It could cite the tenant's right to repairs, set a reasonable deadline, and suggest keeping a written record of the request.
- builder-just-live: Skip the "no card" opener and the Docker requirement. Publish the running app directly on the device with its port and an org-only sign-in for the team, then offer a card for keeping it running later as an option.
