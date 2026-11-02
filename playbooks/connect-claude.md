---
icon: plug
title: Connect Claude to your Edgible
description: Use Claude on your phone, desktop or the web to see and look after your apps, and to store keys safely, through a connector on your own machine.
prev: get-edgible-running
next: your-ai-gateway
---

# Connect Claude to your Edgible

*Chapter 2 of [Your own AI agent, from anywhere](../your-own-ai-agent/). New: tested on our own machines, so [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).*

So far, Claude Code on your computer does the work. This chapter lets **every Claude** do it: the Claude app on your phone, on your desktop, and on the web. Ask what's running, whether something answers, or for a new app, from wherever you are.

It works through a **connector**: a small service on your own machine that Claude's apps call, behind your Edgible sign-in. It also gives you **key links**, so you can store an AI provider's key without ever pasting it into a chat.

> **What you need**
>
> - [Chapter 1](../get-edgible-running/) done.
> - **Claude** on a paid plan, on your computer, and the Claude app on your phone.

## 1. Set up the connector

In Claude Code, on your own computer, say:

> Connect Claude to my Edgible: set up the Edgible connector on my edgible-vm, and allow it to make changes on that machine only.

It sets the connector up on your machine and gives it its own web address. Along the way it asks you to approve one more sign-in, with a link and a code as in chapter 1: that lets the connector act for your Edgible account. It is a separate sign-in from chapter 1's, so check again that the page names the account you mean to use. Claude reads the account back before it goes on.

Along the way it may find and fix small problems, such as the clock on a virtual machine, and it tells you what it did. If you already have a connector, it says so, and you can keep using that one.

At the end, it gives you the connector's address. Copy it: it ends in **`/mcp`**. Lost it? Ask: *"What's my Edgible connector's address?"*

## 2. Add it to Claude

In the Claude app on your computer, or at claude.ai:

1. Open **Settings**, then **Connectors**, then **Add custom connector**.
2. Name it **Edgible**, paste the address, and choose **Add**.
3. Choose **Connect**. An Edgible page opens: sign in with your Edgible account, and allow Claude. This is the third time you sign in to Edgible, and the last: this one lets Claude, not your machine, act for your account. Check the page names the account you mean to use.

That's all. Your phone's Claude app picks it up by itself, since it's the same Claude account.

If Claude says it *couldn't check the server* or *couldn't register*, check the address: it ends in `/mcp`, and it doesn't have `-login` in it. That one is the sign-in page you see, not the connector.

## 3. Try it from your phone

In the Claude app on your phone, start a new chat and ask:

> What's running on my Edgible?

It should list your machine and the connector itself. Claude asks before it changes anything, every time.

## What you've just done

You've put Edgible in your pocket:

- **Any Claude, anywhere.** Your phone, your desktop and the web can all see and look after your apps, not just the computer you set it up on.
- **Only you get in.** Claude reaches the connector through your Edgible sign-in, and it can change things only on the machine you allowed.
- **Keys stay out of chats.** When Claude needs a key, it gives you a one-time link instead. You paste the key there, and it goes straight to your Edgible account.
- **It runs on your machine,** not on someone else's service.

<details>
<summary>Prefer to do it by hand?</summary>

What Claude does, in order. Each step is in the [edgible-connector card](https://github.com/edgible-org/cards/tree/main/edgible-connector)'s README, which our regression runs as written.

1. **On the machine, the edgible-connector card.** In its `card.env`: `DEVICE` (this machine's Edgible name), `ORG_LABEL`, and, to let Claude make changes, `EDGIBLE_MCP_ALLOW_WRITE=1` with `EDGIBLE_MCP_DEVICES` set to this machine. Then Check and Start.
2. **Sign its Edgible tools in,** once: the README's `edgible auth login --no-browser` inside the `edgible-mcp` container, then open the link and approve.
3. **Publish its two addresses:** `mcp-signin` on `none` (the connector) and `mcp-signin-login` on `org` (the sign-in page).
4. **In Claude:** Settings, Connectors, Add custom connector, with `https://<mcp-signin address>/mcp`.

</details>

**See what Claude did.** Every change it makes through the connector is recorded on your machine: ask *"Show me what you've changed on my Edgible"* at any time.
