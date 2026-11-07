---
icon: chat
title: Your agent
description: Your own AI agent, OpenClaw, on your machine, using your AI gateway with its own key and budget, behind your Edgible sign-in.
prev: your-ai-gateway
next: run-it-from-your-phone
---

# Your agent

*Chapter 4 of [Your own AI agent, from anywhere](../your-own-ai-agent/). New: tested on our own machines, so [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).*

Now the agent itself. It's **OpenClaw**, a popular open-source AI agent: it chats, remembers, researches, and uses tools on your behalf. Yours comes with Edgible's tools and skill built in, so it can also look after your apps, asking you first before it changes anything.

It runs on your machine, uses your AI gateway with **its own key and its own budget**, and only you can open it.

> **What you need**
>
> - [Chapters 1 to 3](../your-own-ai-agent/) done: Edgible running, Claude connected, and your AI gateway.
> - **8 GB of memory** on the machine in all. The agent needs about 4 GB on top of the gateway, and with less, it gets stopped mid-answer.

## 1. Ask Claude to set it up

In Claude, say:

> Set up my own AI agent on my edgible-vm, called my-agent. It should use my AI gateway, with a budget of five dollars a month.

Claude does three things, and asks before each:

- **Makes the agent's own gateway key,** with its five-dollar budget. The key goes straight into your Edgible account; neither you nor the agent's settings ever show it.
- **Sets the agent up** on your machine, with your gateway as its only way to reach an AI model.
- **Locks it to you:** the agent's address opens only after you sign in with your Edgible account.

At the end, it gives you the agent's address.

## 2. Meet your agent

Open the address, and sign in with Edgible. You're in OpenClaw: a chat, with your agent on the other side. Say hello:

> What can you do for me?

If the page shows *"Proxy client attribution is required."*, reload it once. It means a request reached your agent without Edgible's sign-in having said who you are, and it can happen just after the agent starts. If it stays in one browser while another browser works, that browser is holding an old session for the same address, from an earlier agent you ran there, say: clear this site's cookies and data, or open the page in a private window, and sign in again. Nothing is wrong with your agent.

Its first answers come from **fast**, your gateway's everyday model. The menu by the message box lets you pick another, such as **smart** for harder questions, or **best** when it really matters.

## 3. Let it look after your apps

Your agent has Edgible's tools, but they need your permission once. Ask it:

> Sign in to Edgible.

It shows a link and a short code, as in chapter 1: open the link, check the code, and approve. Then try:

> What's running on my Edgible?

## 4. Ask what it has spent

> What have you spent so far?

It answers with its own spending against its budget, and only its own. It can't see what your other agents spend: that view is yours, in Claude.

## What you've just done

You have your own AI agent, and it's well brought up:

- **It's yours.** It runs on your machine. Its memory, your files and your conversations stay there.
- **Only you can open it,** behind your Edgible sign-in. No password of its own to leak, and no ports open.
- **It can't run up a bill.** It has its own key and budget on your gateway. At its limit it stops; it never sees your provider keys, and it can't touch other agents' budgets.
- **It knows its own spending,** and you see everyone's.
- **It asks before it acts** on your apps, every time.

Most people trying agents give one a provider key and hope. Yours has guardrails from the first message.

<details>
<summary>Prefer to do it by hand?</summary>

What Claude does, in order. The agent is the [edgible-agent card](https://github.com/edgible-org/cards/tree/main/edgible-agent) in its shared-gateway mode; its README has every step, and our regression runs it as written.

1. **Make the agent's gateway key** in the gateway's admin page: Keys, Create key, named after the agent, with a budget of 5 dollars per 30 days, and allowed routes `/v1/chat/completions`, `/v1/models` and `/key/info`, so it can't read anyone else's spending.
2. **On the machine, the edgible-agent card.** In its `card.env`: `COMPOSE_PROFILES` empty (no gateway of its own), `OPENCLAW_MODEL_URL` set to your gateway's API address ending `/v1`, `OPENCLAW_MODEL_KEY` to the key from step 1, `OPENCLAW_USERS` to the email you sign in to Edgible with, and, to let it change apps, `EDGIBLE_MCP_ALLOW_WRITE=1` with `EDGIBLE_MCP_DEVICES` set to this machine. Then Check and Start.
3. **Publish it** on `org`.
4. **Sign its Edgible tools in,** once: the README's `edgible auth login --no-browser` inside its `edgible-mcp` container, or ask the agent *"Sign in to Edgible"*.

</details>
