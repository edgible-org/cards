---
icon: machine
title: Get Edgible running
description: Put Edgible on a computer that stays on, with your AI assistant doing the technical work. The first chapter of every playbook.
prev: your-own-ai-agent
next: connect-claude
---

# Get Edgible running

This is the first chapter of every playbook. By the end, a computer of yours runs Edgible, ready for apps that you and the people you choose can reach from anywhere.

Your AI assistant does the technical work. You tell it what you want, approve a couple of things in your browser, and answer a few questions. It takes about fifteen minutes.

Done this already? Skip to your playbook.

> **What you need**
>
> - **A computer that stays on:** a Mac, or a PC or small server running Linux, such as Ubuntu. A spare one is ideal. On Windows, Edgible runs in a Linux virtual machine. No suitable computer? See [Getting a machine](../getting-a-machine/): a virtual machine on your own computer, or a small cloud server.
> - **Claude Code,** in the Claude desktop app on your own Mac or Windows computer. It comes with Claude's paid plans. If Edgible is going on another machine, such as a virtual machine or a cloud server, Claude Code sets it up from yours. Other assistants that read skills, such as Codex, work too.
> - **An Edgible account.** It's free during the public beta, and your AI will help you make one.

## 1. Open Claude Code

On your own computer, in the Claude desktop app, switch to **Code**, and choose a folder for it to work in: a new, empty one is fine.

Edgible going on a virtual machine or a server? Claude Code still runs here, on your own computer, and reaches the other machine from here. If you just made a virtual machine with it, carry on in the same session.

Claude Code is the part of Claude that can work on your computer. It always asks before it changes anything.

## 2. Give it the Edgible skill

The skill is Edgible's recipe book for AI assistants: how to set Edgible up, our tested app recipes, and how to look after them. Say:

> Install the Edgible skill from github.com/edgible-org/card-kit

## 3. Ask it to set up Edgible

> Set up Edgible on this computer so I can run my own apps.

For a virtual machine or a server, name it instead, as [Getting a machine](../getting-a-machine/) shows. It checks the computer first, then takes you through the rest. Along the way:

- **Your account.** If you don't have one yet, it sends you to [edgible.com](https://www.edgible.com) to sign up and create an organisation, the name your apps live under. It never asks for your password.
- **A clean slate.** Before anything else, it signs this computer out of Edgible, so nothing is picked up by accident from an earlier sign-in. If the computer was signed in, it first tells you which account, so you know what it's leaving.
- **Signing in, on purpose.** It shows you a link and a short code. Open the link, and check two things: the code matches, and the page names the account you mean to use. Browsers remember sign-ins, so if the page shows another account, such as a work one, sign out of it there or open the link in a private window. Then approve. That's how this computer gets permission to act for your account. Claude then reads the account back to you, for example *"Signed in as jane@example.com, organisation Jane's"*, and carries on only when you say it's right.
- **A name for this computer,** such as `minipc` or `office-mac`. It's how you'll recognise it later.
- **Whether it should stay on.** Say yes for anything other people rely on: Edgible then starts by itself whenever the computer starts.

## 4. Check it worked

> Is Edgible running on this computer?

For a virtual machine or a server, name it here too, such as *"Is Edgible running on the edgible-vm?"*: your own computer may run Edgible as well, and then "this computer" means yours.

It should say the computer is **online**. You can also see it, by the name you gave it, in your [Edgible console](https://app.prod.edgible.com/).

## What you've just done

Your computer is now an Edgible device. That sounds small, and it isn't:

- **It's reachable from anywhere, safely.** Apps on it can get their own web address, with HTTPS and sign-in, and you didn't open a single port on your router or touch your internet settings. Edgible's agent connects out, so nothing on your network is exposed.
- **Your AI can look after it.** It knows how to put apps there and keep them going: checks, backups, upgrades, moving to another machine.
- **It's yours.** Your machine, your data. Nothing is held in someone else's cloud, and nothing is held hostage if you leave.

Not long ago this took an afternoon with a networking guide: domain names, certificates, firewall rules. You did it in about fifteen minutes, in plain sentences.

## What's next

Edgible is running, and your AI knows how to use it. You're done with this chapter: go back to your playbook, or simply say what you need, in your own words. For example:

> It costs us $40 a month to host our small website. Is there a better way?

If something goes wrong, tell your AI what you see. The skill knows Edgible's error messages and their fixes.

<details>
<summary>Prefer to do it by hand?</summary>

These are the commands your AI runs, on macOS or Linux. You need `curl`, `unzip` and Node.js 20 or later.

```bash
# Install the Edgible command-line tool
curl -fsSL https://get.edgible.com/install.sh | bash
export PATH="$HOME/.local/bin:$PATH"

# Start clean, then sign in: open the link it prints, check the account, and approve
edgible auth logout
edgible auth login --no-browser

# Make this computer a device that starts by itself (choose your own name)
sudo ln -sfn "$HOME/.local/bin/edgible" /usr/local/bin/edgible
sudo edgible install --device-name minipc --yes

# Check
edgible agent status
```

The full walk-through is Edgible's [Start here](https://guides.edgible.com/) guide.

</details>
