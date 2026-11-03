---
icon: lock
title: A private model for your agent
description: A playbook for running an AI model on your own GPU machine and giving your agent the choice of it, so private work never leaves your hardware.
next: second-machine
---

# A private model for your agent

*Draft. Chapters 3 and 4, the gateway and your agent, have been run end to end in Claude on a clean machine. Chapters 1 and 2, which use Claude Code on your GPU computer, are tested piece by piece but not yet run as the prompts you'll type, and the screenshots are still to come. You're early, so please [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).*

Some things shouldn't leave your hardware: client documents, medical notes, a half-written contract, your own diary. This playbook adds a **private model** to the agent you built in [Your own AI agent, from anywhere](../your-own-ai-agent/):

- **A real AI model, running on your own computer's graphics chip,** so what you ask it never goes to a cloud provider.
- **A second machine in the story.** The model lives on a machine with a GPU. Your gateway and agent live on another. Edgible lets one call the other safely, with a key, and nothing opened on your network.
- **A choice, not a replacement.** Your agent keeps its everyday models and gains `private` beside them. You pick per question, and you can see what each one costs: the private one costs you electricity, not dollars.

## The road map

Each chapter builds on the one before.

| | Chapter | You end up with |
| --- | --- | --- |
| 1 | [Add a second machine](../second-machine/) | Your GPU computer on Edgible, next to the machine your agent runs on |
| 2 | [Your private model](../your-private-model/) | An AI model on that computer, reachable only with a key |
| 3 | [Private in your gateway](../private-in-your-gateway/) | `private` and `private-smart` in your AI gateway, with a budget and a spending record like any other |
| 4 | [Private for your agent](../private-for-your-agent/) | Your agent offers the private model beside its everyday ones |
| 5 | [Give your agent your own files](../give-your-agent-your-files/) | Your agent reads a folder of your own notes and documents, read-only, and the private model answers from them, so nothing leaves your machines |
| 6 | [Choosing between them](../choosing-between-them/) | Which questions go where, what the private model is good at, and what it isn't |

## What you need

This playbook starts where the agent playbook ends.

- **[Chapters 1 to 5 of the agent playbook](../your-own-ai-agent/) done:** Edgible running on a machine we call `edgible-vm`, with your AI gateway and your agent on it.
- **A second computer with a GPU, which we call `edgible-gpu`.** Any computer where Ollama, the program that runs the model, can use the GPU, and where Edgible runs. We've tested it on a computer with Apple silicon so far, and Edgible's ready-made recipe is for that today; a recipe for Linux computers with an NVIDIA GPU is planned, not ready. Ollama needs to run directly on the computer to use its GPU: inside Docker, on some systems, it can't, and would be several times slower.
- **Enough memory for the model you want.** The model has to fit in the memory its GPU can use, with room for everything else. What we measured, on a computer with 32 GB of memory its GPU can use, for a short answer:

| Model | Size | Speed | First answer, cold | Suits |
| --- | --- | --- | --- | --- |
| `llama3.2:3b` | 2 GB | 43 words a second | 5 seconds | 8 GB of GPU memory. Quick, simple questions. |
| `qwen2.5:7b` | 4 GB | 21 | 6 seconds | 16 GB. Good all-rounder. |
| `gpt-oss:20b` | 13 GB | 25 | 16 seconds | 24 GB or more. Our pick for `private-smart`. |
| `qwen3.5:27b` | 17 GB | 6 | 30 seconds | 32 GB or more. Strong, and slow. |

("Words a second" is tokens a second, close enough to words for reading speed. Your computer will differ. "Cold" includes loading the model, which happens once, after it's been idle.)

Those are short questions. **Your agent is different.** It opens every conversation with about 12,000 tokens of its own instructions and tool descriptions, and the model has to read them before it answers. On our test computer that took **about 80 seconds** with `qwen2.5:7b` the first time: 72 reading, 5 loading the model, 2 answering. Every message after that in the same conversation took well under a second, because the model keeps what it has read. On the same test text, `gpt-oss:20b` read in 19 seconds against 55 for the 7B, plus about 24 seconds to load the larger model once. Leave it for more than five minutes and Ollama unloads the model, so the next conversation pays again.

- **A computer that stays awake.** If it sleeps, the private model is unreachable. `private` never falls back to a cloud model, by design, so it simply doesn't answer. Set it to stay awake when plugged in (your AI can do that), or use one that stays on.
- **Which Claude model:** chapters 1 to 4 change things on your machines, asking your permission first, so choose a Sonnet-class model or better for them. Chapter 5 and everyday questions afterwards are fine on a smaller, cheaper one. We haven't tested smaller models on these steps yet.

- **About an hour,** most of it waiting for a model to download.

## Why a second machine

A GPU is the expensive, noisy, power-hungry part. You may well want it somewhere other than where your always-on agent lives: a computer on a desk, a gaming PC, a workstation. Edgible makes the distance irrelevant. Your gateway on one machine calls the model on another by its Edgible address, with its own key, and neither machine opens a port.

In this playbook we tested with one computer with a GPU, and a virtual machine on it for the other. That works, but it's a stand-in for the real thing: two physical machines, on different networks, behave the same way, and we haven't yet tested that. [Under the hood](../under-the-hood/) says so plainly.
