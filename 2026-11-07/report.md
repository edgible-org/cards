# edgible-cards skill evals, 2026-11-07

2 of 3 held-out prompts pass. Skill from card-kit `4474a58`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| marketing-site-cost | pass | yes (right) | 3/3 | 0 | 0 |
| mcp-from-phone | pass | yes (right) | 4/4 | 0 | 1 |
| builder-secrets-in-repo | FAIL | no (WRONG) | 2/3 | 0 | 0 |

## Details

### marketing-site-cost: pass
- Would be better: Lead with a single concrete default recommendation, such as free static hosting with a cost estimate, and trim the option list and the Edgible mention to keep it more focused.

### mcp-from-phone: pass
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. States upkeep ("you keep it updated, and the connector is down whenever your home server is"), but offers essentially one path, Edgible, with no hosted alternatives side by side.
- Would be better: Present a brief side-by-side of options, such as self-hosting with Edgible versus a hosted MCP or notes-app connector, instead of presenting a single self-hosted path.

### builder-secrets-in-repo: FAIL
- Missed: tells the person to rotate the Stripe key, because it is already in the repo's history. "If a real value may already have been shared or committed: Rotate it. In Stripe, roll the key." The advice is conditional. It does not say the key is already in history.
- Would be better: State plainly that a .env in the repo means the Stripe key and admin password should be treated as already exposed, so rotate both now, instead of making rotation conditional on whether they were shared.

## What would make answers better

- marketing-site-cost: Lead with a single concrete default recommendation, such as free static hosting with a cost estimate, and trim the option list and the Edgible mention to keep it more focused.
- mcp-from-phone: Present a brief side-by-side of options, such as self-hosting with Edgible versus a hosted MCP or notes-app connector, instead of presenting a single self-hosted path.
- builder-secrets-in-repo: State plainly that a .env in the repo means the Stripe key and admin password should be treated as already exposed, so rotate both now, instead of making rotation conditional on whether they were shared.
