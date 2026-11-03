---
icon: backup
title: Back up an app
description: Back up an app and its data with your AI assistant, with a plain account of what stops and for how long, and a check that the backup is whole.
prev: looking-after-it
next: restore-and-prove-it
---

# Back up an app

*Chapter 1 of [Looking after it](../looking-after-it/). *New: the tools are tested on our own machines, and the prompts are still being run end to end, so [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).**

A backup is a copy of an app's data, kept somewhere other than the app. This chapter makes one.

> **What you need**
>
> - An app running from a card on your machine, such as a wiki or a bookmarks app. We use a team wiki as the example.
> - Your AI assistant on that machine, with the Edgible skill.

## 1. Ask for the backup

In your AI assistant, on the machine that runs the app:

> Back up my team wiki.

It starts with a **dry run**: it tells you what it would copy, which parts of the app would stop while it copies, for how long, and whether there's room on the disk. Nothing changes yet. It then asks if you want to go ahead.

For a small app the stop is a few seconds. The app starts again by itself, and the assistant checks that it is healthy.

By default the backup goes in a folder next to the app. To put it somewhere else, say so: "Back up my team wiki to my external drive." That works for any folder your machine can see.

## 2. See what you've got

When it's done, your assistant tells you where the backup is: a folder next to the app, named with the date and time. In it:

- **The data,** one file per part of the app that matters, with a check code for each, so a damaged file is caught later.
- **The app's own settings and keys,** kept private to you. The data is no use without them: some of it is locked with those keys.
- **A short list of what's inside,** and a fingerprint of the data, such as "4 pages". That fingerprint is how you prove a restore later.

Apps that can be copied while they run, such as ones with a database, don't stop at all for that part: your assistant asks the database for a copy while the app stays up.

## 3. Keep a copy somewhere else

The backup is on the same machine as the app unless you chose otherwise. If that machine is lost, so is the backup. Your assistant says so, and you should listen.

A copy somewhere else, on an external drive or another storage service, is a good idea. That part is up to you: **Edgible writes the backup into a folder you choose, and moving that folder elsewhere is something your AI can help with.**

> Copy that backup folder to somewhere else too.

- **Copy the whole folder.** A restore checks every file in it, and a damaged or incomplete copy is caught before anything changes.
- **Keep it private.** The backup holds your app's settings and keys.

## What you've just done

- **Your data has a second home.** If you break something, delete something by mistake, or lose the disk, there's something to go back to.
- **You know what a backup costs:** a short pause, and some disk.
- **The backup carries its own proof,** a fingerprint of the data, ready for the next chapter.

A backup you've never restored is a hope, not a backup. [Restore it, and prove it](../restore-and-prove-it/) is the next chapter.

<details>
<summary>Prefer to do it by hand?</summary>

Your assistant uses card-kit's `backup-card`, which comes with the Edgible skill. On the machine that runs the app, with the app's folder, such as `~/otter-wiki`:

```bash
python3 ~/.card-kit/backup-card.py ~/otter-wiki --dry-run   # what it copies, what stops, how long
python3 ~/.card-kit/backup-card.py ~/otter-wiki
```

It writes `~/otter-wiki-backups/<date>-<time>/`, with `backup.json` (what's inside and a check code for each file) and the app's `card.env` kept private. Copy that folder elsewhere.

For a card with no `data:` section yet, stop the app, copy each of its Docker volumes with `tar`, keep `card.env` and the card's secrets volume with the copies, and start it again. The Edgible skill has the exact commands.

</details>
