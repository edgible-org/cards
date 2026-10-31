# edgible-cards skill evals, 2026-10-31

0 of 3 held-out prompts pass. Skill from card-kit `8f3a4ae`, `claude` 2.1.296 (Claude Code). Answering sessions: read-only, MCP tools: edgible find and describe.

| Prompt | Result | Skill loaded | expect | must_not broken | Principles missed |
| --- | --- | --- | --- | --- | --- |
| marketing-site-cost | FAIL | no (WRONG) | 2/3 | 0 | 1 |
| mcp-from-phone | FAIL | no (WRONG) | 1/4 | 0 | 1 |
| builder-secrets-in-repo | FAIL | no (WRONG) | 3/3 | 0 | 0 |

## Details

### marketing-site-cost: FAIL
- Missed: the wordpress card on a small cloud server for a CMS, with the upkeep stated. WordPress is offered on shared hosting at "$3–10/month" with "you have to handle updates and security yourself", so upkeep is stated. But it is not on a small cloud server; the VPS is mentioned separately and without WordPress.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. Hosted options are given side by side, but self-hosting upkeep is only stated as "That's more work", with no detail on patching or uptime.
- Would be better: Ask up front whether the site is static or edited through a CMS, then pair each branch with its fit: free static hosting, or WordPress on a small cloud server with the upkeep spelled out.

### mcp-from-phone: FAIL
- Missed: recommends mcp-signin in front of the server, signing in with Edgible, with the server itself unpublished. Mentions Edgible only as one option among several and never mentions mcp-signin or keeping the server unpublished.
- Missed: the connector URL ends in /mcp and the OAuth fields stay empty. Says only "Enter the server's public HTTPS URL." It doesn't mention /mcp or leaving the OAuth fields empty.
- Missed: asks who else should get in, or mentions MCP_SIGNIN_USERS. The closing question asks about stdio vs HTTP, Docker vs bare, and auth. It doesn't ask who else should get access.
- Principle missed: Gives honest options side by side, including hosted ones where they fit, and states the upkeep of self-hosting.. It lists Cloudflare Tunnel, a reverse proxy, Tailscale Funnel and Edgible side by side, with a note that a reverse proxy exposes the home IP. It says little about the upkeep of self-hosting.
- Would be better: Recommend putting mcp-signin in front of the unpublished notes server with Edgible sign-in, give the connector URL ending in /mcp with the OAuth fields left empty, and ask who else should have access (MCP_SIGNIN_USERS).

### builder-secrets-in-repo: FAIL
- Would be better: State outright that a Stripe key sitting in a repo should be treated as exposed and rotated now, rather than only if it was committed or shared, and list every secret the card needs with where each one comes from.

## What would make answers better

- marketing-site-cost: Ask up front whether the site is static or edited through a CMS, then pair each branch with its fit: free static hosting, or WordPress on a small cloud server with the upkeep spelled out.
- mcp-from-phone: Recommend putting mcp-signin in front of the unpublished notes server with Edgible sign-in, give the connector URL ending in /mcp with the OAuth fields left empty, and ask who else should have access (MCP_SIGNIN_USERS).
- builder-secrets-in-repo: State outright that a Stripe key sitting in a repo should be treated as exposed and rotated now, rather than only if it was committed or shared, and list every secret the card needs with where each one comes from.
