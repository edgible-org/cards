---
icon: key
title: Private for your agent
description: Your agent offers the private model beside its everyday ones, so you choose per question and see what each costs.
prev: private-in-your-gateway
next: give-your-agent-your-files
---

# Private for your agent

*Chapter 4 of [A private model for your agent](../a-private-model-for-your-agent/). Draft: [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).*

Your agent, `my-agent`, only knows models through your gateway, so it already has what it needs. The model picker in its chat lists everything the gateway offers: `fast`, `smart`, `open`, `best`, and now `private` and `private-smart`.

This chapter is the short one: choose it, and watch what it does to your budget.

> **What you need**
>
> - [Chapter 3](../private-in-your-gateway/) done, with both private checks passing.
> - Your agent from [chapter 4 of the agent playbook](../your-agent/), signed in as usual.

## 1. Pick the private model

Open your agent's address, and sign in with Edgible. In the model menu by the message box, choose **private**. Then say:

> In two sentences, what's the difference between an LLC and a corporation?

Nothing about the chat looks different. The words came from your own computer.

**The first message of a new conversation is slow.** Your agent sends about 12,000 tokens of instructions and tools with it, and the computer has to read them before it answers. We saw about 80 seconds with `private`. Every message after that in the same conversation is quick, because the model keeps what it has read. Leave it for more than five minutes and the computer forgets, so the next conversation pays the wait again. Give it a moment the first time, then carry on.

## 2. Ask it something you'd rather keep to yourself

Try a question you wouldn't type into a cloud service: a paragraph from a private note, a draft you're not ready to share. Ask the agent to summarise it, with **private** selected.

Choosing **private** is what keeps the model's thinking on your hardware. If you switch back to **fast**, the question goes to the cloud, as it always did, so look at the menu before you paste anything sensitive. And remember the agent has tools: if you ask it to search the web or open a link, that part goes where any web request goes. Keep private questions to text you give it.

## 3. See what it cost

> What have you spent so far?

Your agent answers with its own spending against its budget, as before. The private model's questions add almost nothing: the token price we set, a cent or so for a hundred thousand tokens. In Claude, ask *"What has my AI gateway spent, by model?"* to see them side by side.

## 4. Use it for what it's good at

A small model on your own computer is good at a lot: summarising, rewording, drafting, explaining, answering from text you paste in. It's less sure at being an agent on a long job: planning many steps and using many tools without drifting. [Chapter 5](../choosing-between-them/) is about exactly that.

## What you've just done

Your agent now has a private mode:

- **One agent, two worlds.** Cloud models when you want the best answer, your own computer when you want it private.
- **You decide per question,** with one tap in the model menu.
- **The budget still applies.** The private model counts toward your agent's budget at a token price, so nothing runs away.

<details>
<summary>Prefer to do it by hand?</summary>

Nothing to do. The agent's model menu is set by `OPENCLAW_MODEL_CHOICES` in the [edgible-agent card](https://github.com/edgible-org/cards/tree/main/edgible-agent), which lists `private` and `private-smart` by default. If you narrowed the list, add them back, and restart the agent.

</details>
