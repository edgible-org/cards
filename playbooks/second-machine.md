---
icon: machine
title: Add a second machine
description: Put Edgible on your GPU computer, so your gateway and agent on one machine can use a model on another.
prev: a-private-model-for-your-agent
next: your-private-model
---

# Add a second machine

*Chapter 1 of [A private model for your agent](../a-private-model-for-your-agent/). Draft: [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).*

Your agent runs on `edgible-vm`. The private model will run on a computer with a GPU. This chapter makes that computer a second Edgible device, which we'll call `edgible-gpu`, so the two can talk.

It's the first chapter of every playbook again, for a different machine, so it's short.

> **What you need**
>
> - **The computer with the GPU,** awake, and **Claude Code** in the Claude desktop app **on that computer.** Claude Code does the work on the machine it runs on, so this chapter is done there, not from your phone.
> - [The agent playbook](../your-own-ai-agent/) done, so you have `edgible-vm`, and the Edgible skill in Claude Code. If this computer is where you made the virtual machine, you've already done both.

## 1. Set up Edgible on this computer

In Claude Code on that computer, say:

> Set up Edgible on this computer and call it edgible-gpu. It should start by itself when the computer starts.

It checks the computer, then walks you through it as in [Get Edgible running](../get-edgible-running/): it asks before installing the Edgible software, gives you a link and a short code to approve in your browser, and uses the name you gave it. Your computer may ask for its own password once, to start Edgible when it starts.

Already running Edgible on this computer under another name? Say so, and ask it to keep that name instead. One computer, one device.

## 2. Keep it awake

A sleeping computer can't answer. The screen can sleep; the computer can't. Claude Code can set that up for you, whatever your system. In Claude Code on that computer, say:

> Keep this computer from sleeping while it's plugged in.

It tells you what it will change and asks first.

## 3. Check you now have two

In Claude, on your phone or computer, say:

> What machines do I have on Edgible?

It should list both, `edgible-vm` and `edgible-gpu`, and say each is **online**. You can also see them in your [Edgible console](https://app.prod.edgible.com/).

## What you've just done

You now have two machines, and neither opened a port:

- **Each one connects out to Edgible,** so nothing on either network is exposed.
- **Claude can see both** from anywhere, and tells you which is which.
- **They can reach each other's apps,** by their Edgible addresses, with the same sign-in and key rules as any other app. That's what the next chapters use.

<details>
<summary>Prefer to do it by hand?</summary>

On the GPU computer, with `curl`, `unzip` and Node.js 20 or later, the same steps as [Get Edgible running](../get-edgible-running/):

```bash
curl -fsSL https://get.edgible.com/install.sh | bash
export PATH="$HOME/.local/bin:$PATH"
edgible auth login --no-browser
sudo ln -sfn "$HOME/.local/bin/edgible" /usr/local/bin/edgible
sudo edgible install --device-name edgible-gpu --yes
edgible agent status
```

Then `edgible device list` shows both machines.

</details>
