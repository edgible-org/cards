---
icon: govern
title: Your AI gateway
description: Cost guardrails before you run an agent: one place for your AI keys, a budget for every agent, and the spending in real dollars, on your own machine. Use the providers you like, added one at a time.
prev: connect-claude
next: your-agent
---

# Your AI gateway

*Chapter 3 of [Your own AI agent, from anywhere](../your-own-ai-agent/). New: tested on our own machines, so [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).*

Before you run an agent, put the guardrails in. An AI gateway sits between your agents and the AI providers, and gives you:

- **One place for your keys.** You store each provider's key once. Your agents never see them: each gets its own gateway key instead.
- **A budget per agent.** Each agent can spend only its own budget, say five dollars a month. A runaway agent stops at its limit, not at your credit card's.
- **The real dollars.** What each agent spent, on which model, from your phone.
- **Models by purpose, not by name.** Agents ask for *fast*, *smart* or *best*, and you decide which model each one means, and change it any time.
- **A backup.** When a provider has an outage or a free tier runs out, the next one answers.

The gateway is LiteLLM, the most widely used open-source AI gateway, in a version we've tested.

You'll set the gateway up first, then add the AI providers you want to use, one at a time, just by asking.

> **What you need**
>
> - Chapters 1 and 2 done, on a machine with **4 GB of memory** or more.
> - **An account with at least one AI provider, and a little credit.** Any of OpenAI, Anthropic, Google Gemini, DeepSeek, Mistral, Groq or OpenRouter will do. The examples use DeepSeek, which is inexpensive; swap in yours.

## 1. Set up the gateway

In Claude, say:

> Set up an AI gateway on my edgible-vm, called ai-gateway.

It checks the machine, then asks you one thing: whether to give the gateway an address your apps can call. Say yes. That address answers only apps holding a key the gateway gave them, and each app gets its own key and budget. Your connector keeps the gateway's own master key, so you never handle it.

The gateway is running, but it can't answer yet: it has no AI provider. Next.

## 2. Add your first provider

> Add my DeepSeek key to the gateway.

If you stored that key with Edgible before, Claude simply uses it. Otherwise it gives you a **key link**. Open it, paste the key from the provider's page, and save. The key goes straight to your Edgible account, never into the chat. Links work once, for ten minutes, and from your phone too.

Claude then tells you what it's about to do and asks, something like:

> I'll add DeepSeek for **fast** and **smart**. The gateway restarts and doesn't answer for about a minute. OK?

Say yes. When it's back, Claude checks each purpose answers, and reports what it did, in words like these:

> Added DeepSeek. **fast** uses deepseek-chat, **smart** uses deepseek-reasoner. Both answered a test question. Not set up: **best**, **open**, **private**. To change one, say "make smart use …".

You never had to choose a model name or a purpose. A first provider fills **fast** and **smart**, so you have a gateway that works.

## 3. Check it answers

> Check my AI gateway answers.

It sends one tiny question through the gateway, and tells you which provider answered, how long it took, and what it cost: a tiny fraction of a cent.

## 4. Add another provider, any time

Say which provider, in the same way:

> Add my Gemini key to the gateway.

Claude is careful not to change what already works. With DeepSeek already answering, it tells you something like:

> Added Gemini as **fast**'s backup. **fast** and **smart** already use DeepSeek, so I left them. Say "make smart use Gemini" to switch.

So adding a provider is safe: it never quietly sends your questions somewhere new. When you want it to, say so:

> Make smart use Gemini.

> Use OpenAI for fast and smart.

The most expensive purpose, **best**, is never filled unless you ask:

> Add my Anthropic key to the gateway, for best.

Each change restarts the gateway for about a minute.

## The purposes

| Ask for | What it's for | Filled by |
| --- | --- | --- |
| **fast** | Everyday answers | The first provider you add |
| **smart** | Harder questions | The first provider you add |
| **open** | Trying strong open models, through OpenRouter | OpenRouter |
| **best** | When it really matters, and the dearest | Only when you ask |
| **private** | Anything that must not leave your machine | A model you run yourself, on your own GPU computer (a later playbook) |

Change what any of them means by asking: *"Make smart use Gemini Pro."* A purpose that no provider serves yet can't answer, and Claude's report tells you which those are. **fast** gets a backup when you add a second provider.

## What you've just done

You've put the guardrails in before letting an agent loose, which is exactly the right order:

- **Your keys are in one safe place,** stored once, never written into a chat, a file or an app.
- **You chose the providers,** and can add or switch them in a sentence, without touching a model name unless you want to.
- **Every agent you add gets its own key and budget.** If one misbehaves, it stops at its limit, and you can switch it off without touching the others.
- **You'll see the real dollars,** by agent and by model, whenever you ask.
- **It's yours.** No middleman between your agents and the providers, no markup, and nobody else's dashboard.

Most people running agents have none of this, and find out at the end of the month.

<details>
<summary>Prefer to do it by hand?</summary>

What Claude does, in order. The gateway is the [litellm card](https://github.com/edgible-org/cards/tree/main/litellm); its README has every step, and our regression runs it as written.

1. **Store a provider's key** with Edgible, from a file holding just the key, with no newline at the end: `printf '%s' "$KEY" > key.txt`, then `edgible secret set deepseek --from-file key=key.txt`, and delete the file.
2. **On the machine, the litellm card.** Pass the key to it by name in `card.env`, set `LITELLM_FAST_MODEL` and `LITELLM_SMART_MODEL` to that provider's models, such as `deepseek/deepseek-chat` and `deepseek/deepseek-reasoner`, then Check, Start, and publish `litellm` on `org` (the admin page).
3. **Publish its API** as `litellm-api` on `none`, as the README's Share it step shows: it answers only keys the gateway issued.
4. **Check it:** sign in to the admin page as `admin`, with the master key the README's `show` command prints on the machine, and send a test message to `fast`. The admin page is also where you make agents' keys and see spending.
5. **To add a provider later,** give the card its key variable (`OPENAI_API_KEY`, `GEMINI_API_KEY` and so on), set the purposes' model settings to its models, and restart the gateway.

Claude does one more thing you don't need by hand: it gives your connector the gateway's address and master key, so you can ask Claude about spending.

</details>
