---
icon: cube
title: A coding agent in a box
description: An open-source coding agent with limits you set yourself, on money, on your computer, and on your data, in a virtual machine you can reset in seconds.
---

# A coding agent in a box

*New: tested on a Mac, so [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).*

A coding agent is at its most useful when you let it work on its own: write the code, run it, fix what broke, try again. It is also at its most worrying then. It can spend your AI credit in a loop, change files you care about, or send your code somewhere you didn't mean it to go.

This playbook puts the agent in a box, with three limits you set yourself:

- **Money.** The agent never holds your AI provider's key. It gets its own key from your AI gateway, with a budget, say two dollars a month. A runaway loop stops at two dollars, not at your credit card's limit, and you see what every session cost, in real dollars.
- **Your computer.** The agent works in a virtual machine, not on your computer. It can't see your files unless you hand them over, and if a session goes badly, you put the box back as it was, in seconds.
- **Your data.** By default the code goes to the AI provider you pick. When it mustn't leave your machines, point the agent at a private model instead.

Everything in the box is open source: [OpenCode](https://opencode.ai/) for the agent, [LiteLLM](https://docs.litellm.ai/) for the gateway (the [litellm card](https://github.com/edgible-org/cards/tree/main/litellm)), Ubuntu, and [Multipass](https://canonical.com/multipass) for the virtual machine. The examples use DeepSeek for the model, which is inexpensive; any provider the gateway supports works the same way.

> **What you need**
>
> - **A computer with 16 GB of memory** or more, and about 30 GB of disk free. The box takes 8 GB while it runs. These steps were tested on a Mac; Multipass also runs on Windows and Linux.
> - **An AI assistant on that computer,** such as Claude Code or Cursor, to build the box for you. Once the box is built, you use OpenCode inside it.
> - **An account with an AI provider, and a little credit.** DeepSeek, OpenAI, Anthropic, Google Gemini, Mistral, Groq or OpenRouter will do.
> - **No Edgible.** The box doesn't need it. [Where Edgible comes in](#where-edgible-comes-in) is at the end.

## 1. Make the box

Tell your assistant:

> Install Multipass if I don't have it, and make an Ubuntu 26.04 virtual machine called opencode-vm, with 8 GB of memory, 4 CPUs and 30 GB of disk. Put Docker, Node and OpenCode in it. Don't share any of my folders with it.

That last sentence matters. A virtual machine sees none of your files unless you share a folder with it, and a shared folder is a door the agent can walk through. Bring code in with `git clone` instead.

## 2. Put the gateway in the box

> In opencode-vm, set up the litellm card from cards.edgible.org, using its steps up to Start, without Edgible. It should answer only inside the box.

This uses an Edgible card with no Edgible at all: the card is a tested recipe, and publishing it is a separate, optional last step. The gateway answers only inside the box, so nothing outside can reach it. It makes its own passwords as it starts, and keeps them in the box.

## 3. Give the gateway your AI provider's key

Your key goes into the gateway's settings, in the box, typed by you: never into a chat with your assistant. Ask:

> Where in opencode-vm do I put my DeepSeek key for the gateway?

Then open a terminal on the box (`multipass shell opencode-vm`), open the file it names, paste your key after `DEEPSEEK_API_KEY=`, save, and tell your assistant you're done. It restarts the gateway so the key is read, and checks a model answers.

## 4. Give the agent its own key, with a budget

> In opencode-vm, make OpenCode its own gateway key with a budget of two dollars a month, and set OpenCode up to use the gateway's fast and smart models. Don't show me the key.

The agent now asks for *fast* (everyday work) or *smart* (harder problems) and never knows which provider answers. You decide what each name means in the gateway, and change it any time, without touching the agent. Your assistant then asks OpenCode one tiny question through the gateway, and checks that the gateway counted what it cost: a fraction of a cent.

## 5. Save the box as it is now

> Stop opencode-vm and save a snapshot of it called clean.

A snapshot is the box as it is right now: the agent, the gateway, your key, nothing else. After a session that went wrong, or to start the next project fresh, put it back:

> Put opencode-vm back to its clean snapshot.

Putting it back also takes the gateway back, so it forgets what was spent since. Check the spending first if you want to keep it (next).

## 6. Use it, and see what it cost

Open a terminal on the box, go to your project, and start the agent:

```bash
multipass shell opencode-vm
git clone https://github.com/you/your-project && cd your-project
opencode
```

Afterwards, ask your assistant:

> What has OpenCode spent in opencode-vm's gateway so far?

It answers in dollars, against the budget. When the budget runs out, the gateway refuses the agent's next request, until the next month starts or you raise it.

## Where Edgible comes in

Everything above works without Edgible. Add it when you want the box to reach further:

- **One gateway for all your agents.** Run the gateway on a machine that stays on instead of in the box, and publish it with Edgible: every agent you use, on every machine, gets its own key and budget from one place, with one record of what each spent. See [Your AI gateway](../your-ai-gateway/).
- **Show what the agent built.** Publish the app it made, behind Edgible's sign-in, and open it on your phone or send it to someone to try. See [A home for everything you've built](../a-home-for-your-apps/).
- **A private model that's bigger than your laptop.** Run the model on a computer with a GPU, publish it with Edgible, and add it to the gateway as *private*: the code never leaves your machines. See [A private model for your agent](../a-private-model-for-your-agent/).

## What the box doesn't limit

- **The internet.** The agent can download packages and visit websites from inside the box. The box protects your computer, not the internet from the agent.
- **What you hand it.** A key or a password you paste into the agent's chat is the agent's to use. Give it test keys, not your real ones.
- **Where the code goes.** With a hosted model, every file the agent reads goes to that provider. Use a private model for code that mustn't.

## What you've just done

You have a coding agent you can let loose: it can't spend more than you allowed, it can't touch the rest of your computer, and you can put it back as it was in seconds. Every part of it is open source, and every part is yours, from the agent to the gateway that keeps its bills honest.

<details>
<summary>Prefer to do it by hand?</summary>

On a Mac with [Homebrew](https://brew.sh/); on Windows or Linux, install Multipass from [canonical.com/multipass](https://canonical.com/multipass).

```bash
brew install --cask multipass
multipass launch 26.04 --name opencode-vm --memory 8G --cpus 4 --disk 30G
multipass shell opencode-vm
```

In the box:

```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2 nodejs npm git curl jq
sudo usermod -aG docker ubuntu && newgrp docker
sudo npm i -g opencode-ai

mkdir -p litellm
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C litellm cards-main/litellm
nano litellm/card.env        # paste your key after DEEPSEEK_API_KEY=
docker compose --env-file litellm/card.env -f litellm/docker-compose.yml up -d --wait
```

Make OpenCode's key, with a two-dollar monthly budget, straight into a file only you can read:

```bash
umask 077; mkdir -p ~/.config/opencode
docker exec -i litellm-litellm-1 python3 - > ~/.config/opencode/gateway-key <<'PY'
import json, urllib.request
mk = open("/run/card-secrets/LITELLM_MASTER_KEY").read().strip()
body = json.dumps({"key_alias": "opencode", "max_budget": 2, "budget_duration": "30d"}).encode()
req = urllib.request.Request("http://127.0.0.1:4000/key/generate", data=body,
    headers={"Authorization": "Bearer " + mk, "Content-Type": "application/json"})
print(json.load(urllib.request.urlopen(req))["key"], end="")
PY
```

Point OpenCode at the gateway, in `~/.config/opencode/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "gateway": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "My AI gateway",
      "options": {
        "baseURL": "http://127.0.0.1:4000/v1",
        "apiKey": "{file:~/.config/opencode/gateway-key}"
      },
      "models": {
        "fast": { "name": "fast", "limit": { "context": 128000, "output": 8192 } },
        "smart": { "name": "smart", "limit": { "context": 128000, "output": 32000 } }
      }
    }
  },
  "model": "gateway/fast"
}
```

Check it, then see what it cost:

```bash
opencode run "Reply with just the word: ready" < /dev/null
curl -s http://127.0.0.1:4000/key/info -H "Authorization: Bearer $(cat ~/.config/opencode/gateway-key)" \
  | jq '.info | {spend, max_budget}'
```

Save the snapshot, and put the box back later, from your computer (not the box):

```bash
multipass stop opencode-vm
multipass snapshot opencode-vm --name clean
multipass restore opencode-vm.clean
```

</details>
