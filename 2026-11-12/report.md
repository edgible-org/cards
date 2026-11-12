# edgible-cards skill evals, 2026-11-12

1 of 3 held-out prompts pass. Skill from card-kit `eac57b2`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| maritime-law-firm | FAIL | no (WRONG) | 2/5 | 1 | 3 |
| negative-landlord-email | pass | no (right) | 1/1 | 0 | 0 |
| builder-just-live | FAIL | yes (right) | 1/3 | 0 | 2 |

## Details

### maritime-law-firm: FAIL
- Missed: self-hosting as a leading option, for confidentiality, behind org. "Does everything need to stay on firm-controlled infrastructure? That would point toward self-hosting, and I can look at options such as Edgible". Self-hosting is raised only as a conditional question. It is not a leading option, and nothing is said about putting it behind org-only access.
- Missed: who sees which matters is set inside the apps (ethical walls). There is no mention of per-matter access, ethical walls, or conflicts between clients.
- Missed: points to professional rules on confidentiality and AI. It says "Client-privileged material shouldn't go to a third-party service without careful handling", but it cites no professional rules or bar guidance on AI.
- Broke: one shared AI knowledge base with no access rules. It proposes one Q&A knowledge base over all the cases and playbooks and says nothing about access rules or per-matter restrictions.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. The four options are content approaches, not hosting choices. Hosted options are not compared and self-hosting upkeep is not stated.
- Principle missed: Asks at most two or three questions, and only ones whose answers change the recommendation.. It asks five question bullets, several with sub-questions: format and volume, confidentiality, audience, priority, accuracy.
- Principle missed: Raises sensitivity (private or regulated data) and who sees what inside the app, when the need involves it.. It raises privilege and confidentiality but not who sees what inside the app.
- Would be better: Make self-hosting behind org-only login the recommended default, with per-matter access rules or ethical walls and a pointer to bar rules on confidentiality and AI. Compare it with hosted options and state the upkeep, and cut the questions to two or three.

### negative-landlord-email: pass
- Would be better: The email could be a little more direct by stating the two-week delay as the first line and offering a ready-to-send version with fewer placeholders.

### builder-just-live: FAIL
- Missed: publishes the running app on a device, with the port it listens on. It says "You'd run the app on a computer or small cloud server and publish it with Edgible" but never mentions the port the app listens on or concrete publish steps.
- Missed: offers keeping it running later, as a card of their own, without requiring it now. It advises "put it in a container with its data in a named volume" for reliability, but doesn't offer a card of their own as a later step, and the container advice is framed as a recommendation, not a deferred option.
- Principle missed: Answers the question the person asked first, before offering anything else.. It opens with "The best route depends on two things I haven't been able to check yet" and a note on its disabled shell tool, before giving any route.
- Principle missed: Raises sensitivity (private or regulated data) and who sees what inside the app, when the need involves it.. It mentions "data that shouldn't leave your network" only as a reason to self-host, and says nothing about sensitivity or who sees what inside the dashboard.
- Would be better: Lead with a direct answer: publish the running dashboard on its port with org-only sign-in for the team, then lay out the hosted alternative and upkeep, and mention a later always-on card as optional.

## What would make answers better

- maritime-law-firm: Make self-hosting behind org-only login the recommended default, with per-matter access rules or ethical walls and a pointer to bar rules on confidentiality and AI. Compare it with hosted options and state the upkeep, and cut the questions to two or three.
- negative-landlord-email: The email could be a little more direct by stating the two-week delay as the first line and offering a ready-to-send version with fewer placeholders.
- builder-just-live: Lead with a direct answer: publish the running dashboard on its port with org-only sign-in for the team, then lay out the hosted alternative and upkeep, and mention a later always-on card as optional.
