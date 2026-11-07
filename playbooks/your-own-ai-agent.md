---
icon: ai
title: Your own AI agent, from anywhere
description: A playbook for running your own AI agent on a machine you control, used from anywhere, your phone included, safely and with its costs under control.
next: get-edgible-running
---

# Your own AI agent, from anywhere

*New: tested end to end on our own machines. You're among the first to follow it, so please [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).*

AI agents do things for you: they research, write, organise, and use your apps. This playbook gets you one of your own:

- **Running on a machine you control,** so its memory, your files and your conversations stay with you.
- **Usable from anywhere,** your phone included, behind your own sign-in.
- **Safe and secure:** no ports opened, no keys pasted into chats, and it asks before anything risky.
- **With its costs under control:** every agent has its own budget, and you can see what each one spends, in real dollars, from your phone.

## The road map

Each chapter builds on the one before, and each leaves you with something that works on its own.

| | Chapter | You end up with |
| --- | --- | --- |
| 1 | [Get Edgible running](../get-edgible-running/) | A machine of yours, reachable from anywhere |
| 2 | [Connect Claude to your Edgible](../connect-claude/) | Claude on your phone and desktop can see and change your apps, and store keys safely |
| 3 | [Your AI gateway](../your-ai-gateway/) | Cost guardrails: one place for your AI keys, a budget per agent, the spending in dollars |
| 4 | [Your agent](../your-agent/) | Your own AI agent, on your machine, using the gateway |
| 5 | [Run it from your phone](../run-it-from-your-phone/) | Talk to your agent, check on it, and see what it costs, wherever you are |
| 6 | [A home for everything you've built](../a-home-for-your-apps/) | Your own bookmarks app, set up by your agent, with every app you've built in it |

## Why the gateway comes before the agent

An agent works in loops: it thinks, calls a tool, reads the result, and thinks again. Each loop costs money, and a confused agent can loop all night. People running agents without guardrails are the ones with the surprise bills.

So before we let an agent loose, we put the guardrails in. An AI gateway sits between your agents and the AI providers: one address, your keys in one safe place, a budget per agent, and a running total of what each one spends. Welcome to the world of AI gateways. We make it easy.

Want to stop, or start again? [Take it all down](../take-it-all-down/) removes it cleanly, keeping your data or not. Curious how it all works, or asked to vouch for it? [Under the hood](../under-the-hood/) sets out what this playbook does for you that's easy to miss, and its known limits.

## What it adds to your Edgible

Five apps in all, each a web address with its own rule for who gets in. You'll see them in your Edgible console:

| Chapter | App | Its address | What it's for | Who can reach it |
| --- | --- | --- | --- | --- |
| 2 | The connector | `https://mcp-signin.<you>.edgible.app/mcp` | Where Claude's apps call your Edgible tools | Anyone can knock, but only Claude with your permission gets an answer |
| 2 | The connector's sign-in page | `https://mcp-signin-login.<you>.edgible.app` | Where you sign in and allow Claude, and where key links open | Only you and your organisation |
| 3 | The gateway's admin (advanced) | `https://ai-gateway.<you>.edgible.app` | The gateway's own settings page. You won't need it: it asks for the gateway's master key, which your connector keeps and never shows, so you do everything by asking Claude | Only you and your organisation |
| 3 | The gateway's API | `https://ai-gateway-api.<you>.edgible.app` | Where your agents send their AI requests | Anyone can knock, but only agents holding a key the gateway gave them get an answer |
| 4 | Your agent | `https://my-agent.<you>.edgible.app` | Your agent's chat and settings | Only you |

`<you>` is your organisation's name in Edgible, and the first part is the app's name: the chapters suggest these names, and Claude picks another if one is taken. Note the pairs: the gateway's API ends in `-api`, and the connector's sign-in page in `-login`, which is never the address you give Claude. For your exact addresses, ask Claude *"What are my apps' addresses?"*, look in your Edgible console, or, after chapter 6, open your bookmarks.

Nothing is hidden: each chapter ends with the same steps done by hand, and every change Claude makes is recorded on your machine, for you to read back at any time. Some parts have no address at all, such as the Edgible tools behind the connector and inside your agent: nothing outside can reach them except through the apps above. An Edgible account has room for twenty apps during the public beta.

## What you'll need

- **Chapter 1 done,** on a machine with **8 GB of memory** or more: the gateway and the agent need about 6 GB between them while they work.
- **Claude,** on a paid plan, on your computer and your phone. **Which model:** the setup chapters change things on your machines, asking your permission first, so choose a Sonnet-class model or better for them. For everyday questions afterwards, such as what's running or what you've spent, a smaller, cheaper model is likely fine. We haven't tested smaller models on these steps yet: if you try one, [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).
- **An account with an AI provider, and a little credit.** OpenAI, Anthropic, Google Gemini, DeepSeek, Mistral, Groq or OpenRouter will do; you add them in chapter 3, one at a time. We use DeepSeek in the examples: reliable, and cents a day for most people. Five dollars goes a long way.
