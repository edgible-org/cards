---
icon: govern
title: Private in your gateway
description: Add your private model to your AI gateway as private and private-smart, with a budget and a spending record like any other model.
prev: your-private-model
next: private-for-your-agent
---

# Private in your gateway

*Chapter 3 of [A private model for your agent](../a-private-model-for-your-agent/). Draft: [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).*

Your [AI gateway](../your-ai-gateway/) already offers models by purpose: `fast`, `smart`, `best`. It also has two private slots, `private` and `private-smart`, that have been waiting for a model. This chapter fills them with the one on `edgible-gpu`.

Here the second machine earns its keep. The gateway runs on `edgible-vm`. The model runs on `edgible-gpu`. The gateway calls it by its Edgible address, with the key from chapter 2, and Edgible checks that key on that computer before the request reaches anything.

> **What you need**
>
> - [Chapter 2](../your-private-model/) done: the model downloaded, and the key stored as `ollama`.
> - Your gateway from the [agent playbook](../your-ai-gateway/), still called `ai-gateway`.

## 1. Add Ollama to the gateway

It's the same sentence you used to add a cloud provider in [the gateway chapter](../your-ai-gateway/). In Claude, on your phone or computer, say:

> Add my Ollama on edgible-gpu to the AI gateway, with qwen2.5:7b for private and gpt-oss:20b for private-smart.

Name the models you downloaded in chapter 2, so it never guesses. Claude finds your `ollama` app's address and the stored `ollama` key, then tells you what it's about to do and asks, something like:

> I'll add Ollama, at your ollama address on edgible-gpu: **private** uses qwen2.5:7b and **private-smart** uses gpt-oss:20b. The key goes to the gateway by reference. The gateway restarts and doesn't answer for about a minute. OK?

Say yes. The key goes from your Edgible account to the gateway, and is never shown or written into a file. Your other providers and keys are untouched, and so are the keys and budgets of the agents that use them.

Only downloaded one model so far? Leave out `private-smart`, and say so.

## 2. See that it answers

When the gateway is back, Claude has already asked each purpose it changed a tiny question, and reports, in words like these:

> Added Ollama. **private** uses qwen2.5:7b and **private-smart** uses gpt-oss:20b. Both answered a test question, from your GPU computer. To change one, say "make private use …".

You can ask again any time:

> Check my AI gateway answers on private.

It sends one tiny question through the gateway to the model on your GPU computer, and tells you which model answered, how long it took, and what it cost. The first answer after a quiet spell takes longer, while the computer loads the model into memory. Try `private-smart` the same way: the bigger model takes a little longer to load.

## 3. See what it costs

> What has my AI gateway spent, by model?

`private` and `private-smart` appear in the list beside the cloud models, with their questions and tokens counted. We give them a token price, about a cent for every hundred thousand tokens, so budgets still work on them, and it rounds to nearly nothing in the report. Their real cost is your electricity.

## What's different about private

Two rules, both on purpose:

- **`private` never falls back to a cloud model.** If your GPU computer is asleep or off, `private` doesn't quietly send your question to a cloud provider. It says it can't answer. A fallback would defeat the point.
- **`private-smart` falls back to `private`,** the smaller model on the same computer, and nowhere else.

## What you've just done

You've added a model to your gateway that the world never sees:

- **It's one more purpose** in the gateway, picked the same way as `fast` or `smart`, with the same per-agent budgets and spending record.
- **Your agents don't know or care where it runs.** They ask for `private`, and the gateway sends them to your GPU computer.
- **The key is yours to revoke.** If you ever suspect it, delete that one key in Edgible and make another. Nothing else changes.

<details>
<summary>Prefer to do it by hand?</summary>

What Claude does. The gateway is the [litellm card](https://github.com/edgible-org/cards/tree/main/litellm); its README describes both private models and the key.

1. In the gateway's `card.env`, set `LITELLM_PRIVATE_MODEL=ollama/qwen2.5:7b`, `LITELLM_PRIVATE_SMART_MODEL=ollama/gpt-oss:20b`, and `LITELLM_PRIVATE_URL` to your `ollama` app's address, such as `https://ollama.<you>.edgible.app`.
2. Give it the key as `OLLAMA_API_KEY`, from the stored `ollama` secret. The gateway sends it as `Authorization: Bearer <key>`.
3. Restart the gateway, and send a test message to `private` from its admin page.

</details>
