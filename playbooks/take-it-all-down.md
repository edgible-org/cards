---
icon: clean
title: Take it all down
description: Remove what the AI agent and private model playbooks set up, cleanly, keeping your data or deleting it, whenever you want to stop or start again.
prev: a-home-for-your-apps
next: your-own-ai-agent
---

# Take it all down

*An appendix to [Your own AI agent, from anywhere](../your-own-ai-agent/) and [A private model for your agent](../a-private-model-for-your-agent/). Tested on one real setup in October 2026: removing the gateway's private model, the agent, the AI gateway, stored keys and the connector were all run from Claude. Not yet run: the Claude Code prompts for the GPU computer, for deleting an app's data, and for taking a machine off your account.*

You can walk away cleanly at any time, whether you were trying things out, want to start again, or need room for other apps. This page takes both playbooks down in reverse order, so nothing is left behind. Claude asks before each removal.

**Only do the sections that apply.** Each says who it's for. Never added a private model? Skip section 1. Never used your own domain? Skip section 2. And so on. You can stop after any section: what's left keeps working.

> **Keep your data, or delete it?**
>
> Removing an app keeps its data on your machine, so setting it up again under the same name picks up where you left off: your agent's memory, your bookmarks, your gateway's spending history. Deleting the data is a separate, deliberate step, in each section. If you're on a virtual machine and want everything gone, skip to [The shortcut](#the-shortcut-delete-the-virtual-machine).

## 1. Your private model

*For you if you did [A private model for your agent](../a-private-model-for-your-agent/). It comes down first because it was added last. In reverse order:*

**In your agent:** nothing to remove. The private choices in its model menu come from your gateway and disappear when the gateway stops offering them.

**In your gateway.** In Claude, on your phone or computer, say:

> Take Ollama out of my AI gateway.

`private` and `private-smart` go back to waiting for a model, as they were before. The gateway restarts and doesn't answer for about a minute. Its other providers, keys and budgets are untouched.

**On your GPU computer, `edgible-gpu`.** In Claude Code on that computer, say:

> Remove my ollama app, and the key my gateway used for it.

The app is unpublished, and the key is deleted, so it stops working at once. Then, to stop Ollama and its guard on that computer:

> Stop and remove Ollama and its guard from this computer.

Your downloaded models stay on the computer, which is useful if you set up again, but they take a lot of disk: `gpt-oss:20b` alone is 13 GB. To free the space:

> Delete the models I downloaded for Ollama.

*Not necessary if you'd like to keep using Ollama on that computer for something else, or its models for other programs.*

**Undo the keep-awake setting,** if you'd like the computer to sleep again:

> Let this computer sleep again when it's idle.

**Take it off your account** (optional), in Claude Code on that computer:

> Remove Edgible from this computer, and take it off my account.

*Not necessary if you'll use `edgible-gpu` again, or want to keep the computer on Edgible for other apps.* If this computer is where you made the virtual machine (see [Getting a machine](../getting-a-machine/)), leave Edgible on it for now: you may not be done with the VM.

## 2. Your own domain

*For you if you did [Use your own domain](../use-your-own-domain/).*

> Stop using links.yourname.com for my bookmarks.

The app keeps working at its Edgible address. Claude tells you which DNS record you added, and you delete that CNAME at your domain provider. It's the one step only you can do. Do the same for any other app you gave a domain.

## 3. Your bookmarks

*For you if you did [A home for everything you've built](../a-home-for-your-apps/).*

> Remove linkding.

Its bookmarks stay on your machine. Claude's Edgible tools can't delete an app's data, so to delete them too, ask Claude Code on that machine: *"Delete the data of my removed linkding app."* Its sign-in token, which you gave Claude to bookmark your apps, stays stored with Edgible until you delete it (section 5 covers stored keys too):

> Delete my stored linkding token from Edgible.

## 4. Your agent

> Remove my agent, and revoke its gateway key.

Its memory and conversations stay on your machine. Claude's Edgible tools can't delete an app's data, so to delete them too, ask Claude Code on that machine: *"Delete the data of my removed agent app."* Its gateway key stops working at once, so nothing can spend on its behalf. The keys stored for it go with it, and so does anything it was signed in to Edgible with.

## 5. Your AI gateway

> Remove my AI gateway.

This takes down the gateway's second, public address as well, and the master key stored for it. Your provider keys stay stored with Edgible, ready if you set a gateway up again. So does its spending history, on your machine. To remove the keys too:

> Delete my stored AI keys from Edgible.

If you won't use them again, also revoke them at each provider: DeepSeek, Gemini, and any others you added. That's done on their websites, and only you can do it.

## 6. The connector

The connector is how Claude reaches your Edgible, so it comes down last of the things Claude uses, in two places:

1. **In Claude:** Settings, Connectors, then remove **Edgible**.
2. **On your machine:** in Claude Code on your own computer, say:

   > Remove the Edgible connector from my edgible-vm.

## 7. Edgible itself (optional)

To take the machine off your Edgible account and uninstall Edgible's agent from it, in Claude Code:

> Remove Edgible from my edgible-vm, and take it off my account.

Your Edgible account stays, with nothing in it, ready if you come back.

## The shortcut: delete the virtual machine

If you followed [Getting a machine](../getting-a-machine/) and made a virtual machine, you can remove everything on it in one go: the connector, gateway, agent and bookmarks. In Claude Code:

> Delete the edgible-vm virtual machine.

Then tidy what lives outside it:

- **The connector in Claude's settings** (section 6, step 1).
- **The machine's entry in your Edgible account:** *"Take my edgible-vm off my Edgible account."*
- **Your stored keys,** which stay with Edgible until you delete them (sections 3 and 5), and any provider keys you want revoked at their websites.
- **A domain record,** if you used your own domain (section 2).
- **The private model,** if you added one. It lives on `edgible-gpu`, not on the virtual machine, so do section 1 as well.

## What you've just done

You've taken it all down, and you chose what happened to your data. Nothing was locked in: no export to ask for, no account to plead with. That's what owning it means.

<details>
<summary>Prefer to do it by hand?</summary>

Each app's card README ends with a Tear down section, the same steps in order: unpublish, stop, delete the data, remove the card. The cards are [linkding](https://github.com/edgible-org/cards/tree/main/linkding), [edgible-agent](https://github.com/edgible-org/cards/tree/main/edgible-agent), [litellm](https://github.com/edgible-org/cards/tree/main/litellm) (the gateway), [edgible-connector](https://github.com/edgible-org/cards/tree/main/edgible-connector) and [ollama-osx](https://github.com/edgible-org/cards/tree/main/ollama-osx). `edgible app api-keys` lists and deletes an app's keys; `edgible secret delete <name>` removes a stored key; `edgible device` and `edgible agent` commands take a machine off your account and uninstall the agent; `multipass delete --purge edgible-vm` removes the virtual machine.

</details>
