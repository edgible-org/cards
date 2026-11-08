# Use cards with your AI

Describe what you need in your own words. The picture is the path.

![With an AI agent: you describe a need and the agent suggests options from the cards. If a card fits, it deploys it on your machine. If not, it builds a new card with you, and you share it back so the next person finds it](about/ai-loop.svg)

## What you need

- **An AI agent that runs commands on your machine.** For the first setup, choose a local rather than cloud-based agent. Thereafter, you can manage your apps anywhere, including as a chat in the [Claude App](#the-claude-app).
- **Claude Code (recommend).** Cursor, OpenCode, and Codex are tested too. Other agents that read skills also work, and we're measuring them.
- **A computer that stays on,** with Docker for the cards that need it.
- **The usual tools,** if the computer is new. A Mac needs Command Line Tools, [Homebrew](https://brew.sh), and Docker Desktop. Windows needs WSL2 with Ubuntu. Linux needs Docker and Node.js 20 or later. Your agent checks, and asks before installing.

## Get started

Say these to your agent, one at a time. [Get Edgible running](playbooks/get-edgible-running.md) walks through them.

> Install the Edgible skill from github.com/edgible-org/card-kit

The skill is what teaches your agent about cards. To check it's there, ask: "What can you do with Edgible cards?" To get the latest version later, ask: "Update the Edgible skill."

> Set up Edgible on this computer so I can run my own apps.

It checks your computer, helps you make a free account, and asks before anything changes.

<details>
<summary>Installing the skill by hand</summary>

<p>For Claude Code:</p>

```bash
git clone https://github.com/edgible-org/card-kit.git ~/.card-kit
mkdir -p ~/.claude/skills
ln -s ~/.card-kit/skills/edgible-cards ~/.claude/skills/edgible-cards
```

<p>For Cursor, Codex, Windows and other agents, see <a href="https://github.com/edgible-org/card-kit#install-the-skill">Install the skill</a> in card-kit. To update by hand, run <code>git -C ~/.card-kit pull</code>, then start a new chat.</p>

</details>

## Ask in your own words

No special phrasing. Talk to it the way you'd talk to a friend who knows self-hosting. [Needs](../needs/) lists every need, and on each page the lines under What people say are ones you can hand to your AI:

- "Pocket is shutting down. I want to keep my saved articles and still read them on my phone."
- "Get Uptime Kuma running so I hear when my site goes down."
- "What's running, and is it all healthy?"

More, with what a good answer does, in [What to ask](https://github.com/edgible-org/card-kit/blob/main/skills/edgible-cards/EXAMPLES.md).

## When no card fits

Your agent doesn't stop at "there's no card for that":

1. It shortlists apps for your need from awesome-selfhosted, maintained and with a container image, and you pick one.
2. It writes a new card for it, in the same shape as every other card.
3. It tests the card end to end on your machine, with the same test the nightly regression runs, and shows you the result.
4. With your yes, it opens a pull request to [edgible-org/cards](https://github.com/edgible-org/cards), with the test result in it. Once it's reviewed and merged, the regression keeps testing it, and the next person's agent finds it.

If it can't make a card pass, it offers to open an issue instead, with what it tried. A fix to an existing card goes the same way.

Built the app yourself? [Add your app](ADD-YOUR-APP.md) shows the whole path, from your app to a card anyone can run.

## What it always asks you first

- Publishing an admin or personal page open to anyone.
- Installing software on the machine itself (a native card), or giving a container control of Docker.
- Stopping, changing or deleting anything it didn't set up, deleting data, upgrades, and moves. It backs up first.
- Anything that leaves your machine, such as a pull request or an issue.

It never shows your passwords in the chat. They stay in the card's `card.env` on your machine, and it tells you which line holds the one you need.

## Connect with MCP

The skill teaches an agent how to work with cards. The edgible-mcp server gives any [MCP](https://modelcontextprotocol.io) client tools that answer from the live catalog and your Edgible account:

- **find** searches the cards for a need in your own words, with how well it suits Edgible and how to publish it.
- **describe** shows one card: its apps, auth modes, minimum machine, and test status.
- **whats_running** lists your devices and apps, and checks that each hostname answers the way its auth mode says.
- **With writes allowed:** deploy a card, move, restart or remove an app, add your own domain, and keep keys out of the chat.

There are two ways to connect it:

- **On your own computer**, over stdio, using that computer's `edgible` sign-in. See [card-kit's edgible-mcp](https://github.com/edgible-org/card-kit/tree/main/edgible-mcp#run-it).
- **From anywhere**, with the [edgible-connector](edgible-connector) card: the server on a machine of yours, added as a connector in the Claude App. Claude Code and other clients that send a header can use the [edgible-mcp](edgible-mcp) card, behind an API key.

### The Claude App

Once a computer is set up, you can choose, deploy, check, and remove apps from the Claude App, on desktop, web, or phone, through the [edgible-connector](edgible-connector) card. Every change asks you first. Find and describe show the cards, and whats_running shows your apps.

The first setup still needs an agent that runs commands, such as Claude Code. The Claude App cannot set up a computer itself.

<details>
<summary>The skill in the Claude App</summary>

<p>Upload <a href="https://github.com/edgible-org/card-kit/releases/download/skill/edgible-cards.zip">edgible-cards.zip</a> under Customize, Skills. It is rebuilt on every change, and updating means uploading it again. Tested in November 2026: Memos chosen and deployed from Claude Desktop's chat.</p>

</details>

The skill knows what to ask, and the tools give it fresh answers without a terminal.

### What's coming

- **A public finder.** find and describe with no sign-in, which you'll be able to add as a connector in the Claude App and ChatGPT.
- **More to check.** Backup and health status for each app in whats_running, as those features land.
- **Measured on more agents.** We'll test the skill and these tools on other agents and models, and show the results here.

## Without a terminal

In Claude's desktop or web app, the skill runs in a sandbox that can't reach your machine. It still helps you choose, and then gives you each command to run yourself, one step at a time, and reads what you paste back.
