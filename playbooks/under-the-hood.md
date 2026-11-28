---
icon: eye
title: Under the hood
description: What the AI agent playbook does for you that's easy to miss, for experts and the curious: how your data, keys and costs stay under your control.
---

# Under the hood

*For the experts and the curious, alongside [Your own AI agent, from anywhere](../your-own-ai-agent/).*

The playbook reads as a handful of plain sentences to an AI. Behind them, a lot happens that's easy to miss. This page sets it out, so that you, or someone you ask, can judge whether it's done properly. Everything here was built and tested on our own machines; where something isn't done yet, the last section says so.

The theme is one idea: **keep your data close, with confidence.** Close, because it runs on a machine you control. Confidence, because what's close is also locked down, costed and recoverable.

## <span class="ico" aria-hidden="true"><svg><use href="../icons.svg#machine"/></svg></span>Where Edgible comes in

Three kinds of thing work together in this playbook. **Open-source apps** do the jobs: OpenClaw the agent, LiteLLM the gateway, linkding the bookmarks. **Our open recipes and skill** (the cards, card-kit and the Edgible skill for AI assistants) set them up the same tested way every time. And **Edgible**, the platform, gives each app a safe way to be reached and run. This is Edgible's part, and what you'd otherwise put together yourself:

| What you get | What Edgible does | Without Edgible, you'd need |
| --- | --- | --- |
| Apps reachable from anywhere, with no ports opened | A small agent on your machine connects out to Edgible, which carries each app's traffic in | A static address or dynamic DNS, open ports on your router, or a VPN or tunnel service you run |
| A web address and HTTPS for every app | Generates each app's address and issues and renews its certificate; your own domain with one CNAME | A domain, DNS records and a certificate tool for each app |
| Sign-in in front of every app | Edgible's own sign-in, per app: only your organisation, open, or a key; it passes the signed-in person's email to the app and strips any forgery | An identity server such as Authelia or Authentik, set up for each app |
| Keys kept out of files and chats | Organisation secrets, stored once and handed to apps by reference when they start | A secrets manager, or keys in settings files on the machine |
| Apps described, not hand-built | Each app is a declaration: what runs, where, how it's reached and with which secrets, applied in one step and changed in place | Scripts and notes per machine, and remembering what you did |
| A fleet you can see and steer | Your machines and apps in one console and one command line, each machine's agent updating itself and rolling back if an update fails | Logging in to each machine to check on it |
| Moving to another machine | Starts the app on the new machine, switches its traffic over, then stops the old copy | Backing up, copying, reconfiguring and re-pointing DNS by hand |
| AI that can help, safely | An official command line and MCP tools that AI assistants use, signed in with a code you approve | Giving an AI broad access to your machine, or doing it all yourself |

Everything Edgible doesn't do is open and yours: the apps, the recipes and the data. The recipes run without Edgible too, with a reverse proxy of your choosing. Edgible is what makes them reachable, signed-in and steerable without the plumbing.

## <span class="ico" aria-hidden="true"><svg><use href="../icons.svg#home"/></svg></span>1. Nothing exposed by default

- **No inbound ports.** Edgible's agent on your machine connects out to Edgible. Nothing on your router or firewall is opened, and your machine's own address is never published.
- **Every page sits behind your Edgible sign-in** unless it has to be open: the gateway's admin, the connector's sign-in page and your agent all use it.
- **The few open addresses answer only credentials you authorised.** The connector answers only Claude, with a token issued after you signed in and allowed it. The gateway's API answers only keys it issued itself. Linkding is open so its browser extension and phone apps can reach it, behind its own sign-in.
- **Your agent trusts only Edgible's sign-in.** OpenClaw runs in trusted-proxy mode: it takes your identity from a header that Edgible's front door sets, and strips from anything a client sends, and admits only the email addresses you named. It trusts that header from one address only, the proxy in front of it.

## <span class="ico" aria-hidden="true"><svg><use href="../icons.svg#lock"/></svg></span>2. Keys never travel through chat

- **Key links.** When a key is needed, Claude gives you a one-time link that works for ten minutes, and you paste the key there. Claude never sees it, and it never sits in a chat history.
- **Provider keys are stored once,** as Edgible organisation secrets, and passed to apps by reference when they start. They're never written into a settings file or an app's configuration.
- **Passwords are made on your machine,** at the app's first start, by a small helper that never shows them again. The one exception is a first-use password a person needs, shown to you once and meant to be changed at once.
- **The gateway's master key is kept by your connector** and shown to nobody, Claude included. Claude asks the connector to make keys and report spending; it never handles the master key itself.
- **Logs are treated as secret.** The gateway's own logs record callers' keys, so our tools read only app names, models and numbers from them, and never pass a key on.

## <span class="ico" aria-hidden="true"><svg><use href="../icons.svg#govern"/></svg></span>3. Least privilege, by default

- **Each agent has its own key,** with its own budget, limited to the routes it needs: asking models, listing them, and reading its own record. It can't read other agents' spending or reach the gateway's admin.
- **What you see depends on who's asking.** Through Claude, the owner sees every agent's spending by model. An agent sees only its own, and says so.
- **The connector may change only the machines you allowed,** and Claude asks before every change: setting up, moving, restarting or removing an app, changing a budget, giving an app your domain.
- **Every change is recorded** on your machine: what, when, on which machine, and that you agreed. Ask Claude to show it at any time.

## <span class="ico" aria-hidden="true"><svg><use href="../icons.svg#record"/></svg></span>4. Costs that can't run away

- **Every agent has a budget,** and stops at it. The dearest model, `best`, has its own cap on top.
- **Backups only go sideways or down.** When a provider fails, the request falls to a cheaper or equal model, never a dearer one.
- **Private stays private.** A model on your own machine never falls back to one on the internet.
- **You can check the real dollars any time,** by agent and by model, and a test question costs a tiny fraction of a cent.

## <span class="ico" aria-hidden="true"><svg><use href="../icons.svg#tested"/></svg></span>5. Software you can trust

- **Exact, tested versions.** Each app runs a pinned version that our regression has set up from scratch, published, checked and torn down.
- **Tested where it runs.** We test on the hardware people actually use, ARM included. That's how we found that one LiteLLM release's ARM image held Intel programs: it ran on a Mac only because the Mac quietly emulated them, and failed on real ARM Linux. We moved to a version that works, and [reported it](https://github.com/BerriAI/litellm/issues/47887).
- **No automatic upgrades.** A new version reaches you only after it has been tested, never because it was released. LiteLLM's own supply-chain incident in March 2026 is the reason it matters.
- **Agents are told the house rules.** The Edgible skill tells assistants to ask before risky steps, give honest advice, including when not to self-host, never print a secret, and stop at the first failure rather than work around it.

## <span class="ico" aria-hidden="true"><svg><use href="../icons.svg#recipe"/></svg></span>6. No black box, no lock-in

- **Every step can be done by hand.** Each chapter ends with the same steps without AI, taken from the card READMEs our regression runs exactly as written.
- **Open-source apps, on your machine:** OpenClaw, LiteLLM, linkding. Your data is in your machine's volumes, classified so backups and moves know what matters.
- **Moving is built in.** An app can move to another machine, data and all, with a check that the data arrived intact.
- **Your own domain** for any app, with HTTPS, without interrupting it.

## <span class="ico" aria-hidden="true"><svg><use href="../icons.svg#machine"/></svg></span>7. Two machines, one private model

For [A private model for your agent](../a-private-model-for-your-agent/), which adds a GPU machine to the picture:

- **Ollama never faces your network.** It listens on that computer only. What Edgible publishes is a small guard in front of it, which tells Ollama the request came from the computer itself, because Ollama refuses anything else. That's why we don't just open Ollama to the network: it has no sign-in of its own, so everyone on your wifi would be able to use your GPU and change your models.
- **A key can use the model, not change it.** The guard passes on asking, chatting and listing models, and refuses downloading, copying, creating and deleting them. Edgible checks the key itself, on that computer, before a request reaches the guard.
- **The key is made for one caller and stored once.** The gateway holds it by reference from your Edgible account, never in a file or in chat, and you can end it alone.
- **`private` never leaves.** It doesn't fall back to a cloud model, so an asleep computer gives you silence, not a leak. `private-smart` falls back only to `private`.
- **Each downloaded program is checked** against its publisher's checksum before it is unpacked.

## <span class="ico" aria-hidden="true"><svg><use href="../icons.svg#map"/></svg></span>Known limits

We'd rather you heard these from us:

- **The ready-made recipe is for computers with Apple silicon today.** A recipe for Linux with an NVIDIA GPU is planned.
- **We tested two machines on one computer** (a computer with a GPU and a virtual machine on it), not two physical machines on different networks. The path between them is the same Edgible address either way, but we haven't proved it across networks yet.
- **The guard is a workaround.** Edgible can't yet forward a host name of your choosing to an app, which publishing Ollama directly would need, so a small guard does that part. It works, and it adds one more program to keep up to date.
- **A small local model is a less steady agent than a cloud one on long jobs.** A single tool call works, but a long, many-step session drifts. It is a good private reader and writer; give your agent a cloud model for long jobs with many tools.

- **Your agent can't give you key links yet,** so storing a key happens in Claude, not in the agent's chat.
- **A lost first-use password needs a terminal** to recover today. A no-terminal way is planned.
- **Two copies of the same app on one machine** can clash over a port, so for now, one of each per machine.
- **A virtual machine is on only while your computer is.** It's right for trying things out, not for apps other people rely on.
- **Edgible is in public beta.** An account holds twenty apps for now, and when a machine loses its internet connection, its link to Edgible can take a restart to recover.
