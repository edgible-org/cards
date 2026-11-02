---
icon: cube
title: Your private model
description: Run an AI model on your computer's GPU with Ollama, behind a key, so only your own gateway can use it.
prev: second-machine
next: private-in-your-gateway
---

# Your private model

*Chapter 2 of [A private model for your agent](../a-private-model-for-your-agent/). Draft: [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).*

The model runs in **Ollama**, a popular open-source program for running AI models on your own computer. Edgible's Ollama recipe for your system installs it to use the computer's GPU and puts a key in front of it.

Two details are worth knowing, because they're why this is safe:

- **Ollama listens on that computer only.** Nothing else on your network, not another computer, a guest on your wifi, or anything that gets into one, can reach it directly.
- **The address Edgible gives it is a small guard in front.** It lets a caller *use* the model and nothing else: no downloading, deleting or changing models. A key can use your models and can't change them. You change them on that computer.

> **What you need**
>
> - [Chapter 1](../second-machine/) done, and **Claude Code on that computer.**
> - **Free memory for the model you pick,** and a few gigabytes of disk. [The table on the front page](../a-private-model-for-your-agent/) says what suits your computer. If you're unsure, start with `qwen2.5:7b`.

## 1. Ask Claude Code to set it up

In Claude Code on the GPU computer, say:

> Set up Ollama on this computer so my AI gateway can use it privately.

It tells you what it's about to install, and asks first: **Ollama** and **Caddy** (the small guard), each checked against its publisher's checksum before anything is unpacked, and two background services that start when you log in. It then publishes the guard on Edgible as an app, `ollama`, that needs a key.

If another Ollama is already running on this computer, it says so and picks a free port rather than taking over. Your existing models can be reused: say so when it asks where models live.

## 2. Download a model

> Download the qwen2.5:7b model.

It downloads onto that computer, on your own connection, and takes a few minutes. A bigger model takes longer: `gpt-oss:20b` is 13 GB. Download a second, larger one now if it has the memory, for `private-smart`:

> Download the gpt-oss:20b model too.

## 3. Check it works, and is locked

> Check my private model runs on the GPU, and that its Edgible address needs a key.

It asks the model a tiny question on the computer and confirms it ran entirely on the GPU. Then it calls the Edgible address without a key, and expects to be turned away. It should tell you it was.

## 4. Make a key for your gateway

> Make an Edgible API key for my ollama app, for my AI gateway to use, and keep it safe in my Edgible account.

Name the `ollama` app, so it can't mean something else: a key for an app that calls the gateway is a different thing, with its own budget. Claude tells you what it's about to do, something like *"make a key named `ai-gateway` for the `ollama` app and store it as the secret `ollama`"*, and asks. You never see the key and it never goes into the chat. If the gateway is ever compromised, you delete that one key and nothing else changes.

Already have a key stored from an earlier try? Claude says so, and warns that making a new one deletes the old: anything still using it stops until it's given the new one. In chapter 3, adding Ollama to the gateway gives it the new key and restarts it.

## What you've just done

You have a private AI model, and it's well guarded:

- **It runs on your hardware.** What you ask it never leaves your computer.
- **Only a key opens it,** and each key can be named, given an end date, and switched off alone.
- **A key can use it but not change it.** Nobody holding a key can download, delete or replace your models.
- **Nothing on your network can reach it directly,** including other computers at home.
- **Its address is on Edgible,** so your gateway, on another machine, can reach it from anywhere.

<details>
<summary>Prefer to do it by hand?</summary>

What Claude Code does, in order. The recipe is Edgible's Ollama card for your system; today that is the [ollama-osx card](https://github.com/edgible-org/cards/tree/main/ollama-osx), for computers with Apple silicon. Its README has every step, and our regression runs it as written.

1. **Fetch the card**, set `DEVICE` to `edgible-gpu` and `ORG_LABEL` to your organisation's name in `card.env`, and run its Check.
2. **Install**: `sh ollama-osx/install.sh` with `card.env` exported. It stops, naming the program, if either port is in use.
3. **Pull a model** on that computer: `curl http://127.0.0.1:11434/api/pull -d '{"model": "qwen2.5:7b"}'`.
4. **Publish** the app `ollama` on `api-key`, as the README's Publish step shows.
5. **Make the gateway's key** with `edgible app api-keys create --app ollama --name gateway`. It is shown once: store it straight away with `edgible secret set ollama`, from a file that holds only the key, and delete the file.

</details>
