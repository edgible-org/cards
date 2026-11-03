---
icon: map
title: Choosing between them
description: Which questions to send to your private model and which to the cloud, what the private model is good at, and what it isn't.
prev: give-your-agent-your-files
next: take-it-all-down
---

# Choosing between them

*Chapter 6 of [A private model for your agent](../a-private-model-for-your-agent/). Draft: [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).*

You now have both. This last chapter is a rule of thumb, and an honest account of the trade.

## The rule of thumb

Ask yourself one question first: **would I mind if this left my computer?** If so, use **private**. If not, use whatever's best for the job.

| Task | Use | Why |
| --- | --- | --- |
| Summarise or reword text you paste in | private | Small models do this well, and the text stays home |
| Draft an email, a note, a plan | private, or fast | Both are fine; private if the content is personal |
| Questions about a document you paste in | private-smart | More room to follow a long text |
| Anything involving a client, a patient, a contract, your health or money | private-smart | This is what it's for |
| Quick everyday questions | fast | Quickest and a fraction of a cent |
| Hard reasoning, maths, careful analysis | smart or best | Cloud models are still ahead |
| An agent doing a long job with many tools | fast, smart or best | Small local models drift on long, many-step jobs; see below |

## What the private model is good at

- **Privacy,** which nothing else gives you. The question and the answer stay on your hardware, and Edgible's part is the key that lets your gateway reach it.
- **Cost that doesn't surprise you.** There's no bill, whatever the agent does. A runaway agent costs you warm air, not dollars.
- **Always the same.** A cloud model is retired or changed on someone else's schedule. Yours changes when you say.

## What it isn't good at, yet

We measured these on a computer with 32 GB of memory its GPU can use. Yours will differ, but the shape won't.

- **The start of an agent conversation.** The numbers below are for short questions. Your agent opens every conversation with about 12,000 tokens of instructions and tools, and a local model reads them at the pace of its hardware: 80 seconds with `qwen2.5:7b` on our test computer, then under a second per message for the rest of that conversation. The wait comes back after five idle minutes, when the computer unloads the model. It is a cost per conversation, not per message, so a few long conversations suit a private model better than many short ones.
- **Speed.** A small model answers a short question almost at once. The 20 billion parameter one is fine. The biggest we tried, `qwen3.5:27b`, produced about six words a second, and took half a minute for a short answer once you count loading it. Good for a document you leave running. Slow for a chat.
- **Memory.** A model needs about its own size in memory *on top of* everything else on the computer. A model that nearly fits makes everything slow.
- **Long jobs with many tools.** A single tool call works: we asked both `qwen2.5:7b` and `gpt-oss:20b` for the weather in Paris with a weather tool on offer, three times each, and every time they called it correctly. What we saw go wrong was a long agent session on a small model with a full set of tools: slow, mostly at the start of each conversation (above), and clumsy. Cloud models are still the safer choice for that. Use private for what you say and ask, and a cloud model for a long job you want your agent to *do*, unless you've tried a local model on your own tasks and it holds up.
- **Strength.** A 7 billion parameter model is not a cloud model. For hard problems it will be wrong more often, and say it with the same confidence. Check what matters.

## Keep an eye on

- **Is the GPU computer awake?** `private` doesn't fall back, by design. "It can't answer" means check that computer.
- **Which model did you pick?** The menu in your agent says.
- **Disk.** Models are big. `ollama` on that computer lists them; delete the ones you don't use.

## What you've just done

You've built something most people don't have: a way to use AI that matches the sensitivity of the question.

- **Your own hardware, used well,** for the work that must stay home.
- **Cloud models, used on purpose,** for the work that's better there.
- **One agent, one gateway, one place to see what everything costs.**
- **No ports opened,** on either machine, and no key shown to anyone.

The next time someone says "I'd use AI for that but I can't put it in a cloud service", you know what to tell them.

Want to stop, or start again? [Take it all down](../take-it-all-down/) removes the private model and everything else cleanly, in reverse order, keeping your data or not.
