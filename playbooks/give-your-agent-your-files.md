---
icon: data
title: Give your agent your own files
description: Let your own AI agent read a folder of your notes and documents, read-only, and answer questions about them from your phone.
prev: private-for-your-agent
next: choosing-between-them
---

# Give your agent your own files

*Chapter 5 of [A private model for your agent](../a-private-model-for-your-agent/). New: tested on our own machines, from a phone, so [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).*

So far your agent knows what you tell it and what's on the web. This chapter lets it read **your own files**: a folder of notes, appointments, recipes, club minutes, anything you keep as text. Then you can ask from your phone, *"When's my dentist?"*, and it looks it up in your files, on your machine.

With your private model answering, nothing here leaves your machines: not your files, and not your questions. It's the first thing your agent can do that you couldn't give it before, and it's read-only: your agent can read the folder, never change it.

> **What you need**
>
> - [Chapters 1 to 4 of this playbook](../a-private-model-for-your-agent/) done: your agent running on your machine, offering your private model beside its everyday ones.
> - A folder of files **on that machine**: text, Markdown or similar. A few notes are enough to start.
> - **A capable model.** Small models fumble tools. Use `private-smart`, the 20 billion parameter model, as we did; the 7 billion one lost its way. A gateway model such as **fast** or **smart** works too, but then what the agent reads goes to that provider.

## 1. Ask your AI to give your agent the folder

In your AI assistant on the machine (or in Claude, if it can reach it):

> Give my agent read-only access to the folder /home/me/notes, using the filesystem MCP server. Check that it can read the folder but not change it.

Change the folder to yours. It does three things, and tells you what it's doing:

- **Mounts the folder read-only** into your agent, as `notes` in its own workspace and as `/notes`, so even a mistake can't change a file.
- **Adds the filesystem server** to your agent as `notes`, with only its reading tools: list, read and search. Writing, editing and moving are switched off.
- **Restarts your agent** so it picks the folder up.

## 2. Ask it a question about your files

Open your agent, on your computer or your phone, and pick `private-smart` from the menu by the message box. If it has been used a lot already, send `/new` first, for a clean start: an agent that has gone looking in the wrong place tends to keep doing it. Then ask:

> Look in my notes folder and tell me what time my dentist appointment is.

Your agent lists the folder, reads what looks relevant, and answers from it. Two things that trip people up:

- **Its search finds file names, not words inside files.** It copes by listing the folder and reading, which is why a folder of a few dozen files works better than thousands.
- **Small models fumble.** A model on your own machine with a few billion parameters may lose its way; your gateway's **fast** or **smart** is better. If it can't find the folder, say "the notes folder, with your notes tools".

## 3. Check it can't change anything

> Add the line "Buy milk" to shopping.md in my notes folder, then tell me whether it worked.

The file stays as it was. Agents sometimes say a thing worked when it didn't, so **look at the file** instead of trusting the reply: that's the point of read-only, and why we show it to you.

## What you've just done

- **Your agent can read your own files,** and answers from your phone, with your documents staying on your machine.
- **It can't change them.** The folder itself is locked read-only on your machine, so whichever of the agent's tools tries to write, it fails. The notes server also has its writing tools switched off.
- **You added a new ability without writing code,** using one of the open MCP servers any agent can use. The same steps work for others.

Honest limits: it reads text, not scans or photos, and it only sees that one folder. Add more folders, or other servers, the same way.

Why your agent, not Claude's app? When you ask your agent with the private model, your files and your question stay on your machines. Claude's own app can reach your files too, through a connector, but then it reads them on Anthropic's side, so we don't recommend that for private notes.

Next, [choosing between them](../choosing-between-them/): which questions go to the private model, and which don't. Done with it all? [Take it all down](../take-it-all-down/) removes it cleanly.

<details>
<summary>Prefer to do it by hand?</summary>

This is the notes folder setting of the [edgible-agent card](https://github.com/edgible-org/cards/tree/main/edgible-agent).

**A new agent:** in the card's `card.env`, set `OPENCLAW_NOTES_DIR` to the folder's absolute path before the first Start. Start sets up everything below on its own.

**An agent that's already running:** the setting only applies at the first Start, so do it in two parts.

1. In `docker-compose.yml`, under the `openclaw` service's `volumes:`, add `- /home/me/notes:/notes:ro` and `- /home/me/notes:/home/node/.openclaw/workspace/notes:ro`, and bring the agent up again.
2. Add the server, with its reading tools only:

```bash
docker compose --env-file edgible-agent/card.env -f edgible-agent/docker-compose.yml run --rm --no-deps openclaw-cli mcp add notes --command npx --arg -y --arg @modelcontextprotocol/server-filesystem@2.1.0 --arg /notes
docker compose --env-file edgible-agent/card.env -f edgible-agent/docker-compose.yml run --rm --no-deps openclaw-cli mcp tools notes --include read_text_file,read_multiple_files,list_directory,list_directory_with_sizes,directory_tree,search_files,get_file_info,list_allowed_directories
```

Check it with `mcp probe notes`: it should list 8 tools.

</details>
