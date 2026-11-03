---
icon: tested
title: Restore it, and prove it
description: Restore a backup as a copy beside your running app, check that it holds the same data, and learn how to put a backup back in place if you ever need to.
prev: back-up-an-app
---

# Restore it, and prove it

*Chapter 2 of [Looking after it](../looking-after-it/). *New: the tools are tested on our own machines, and the prompts are still being run end to end, so [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).**

A backup you've never restored is a hope. This chapter turns it into a fact: you restore it beside your running app, without touching the app, and check that it holds the same data.

> **What you need**
>
> - [Chapter 1](../back-up-an-app/) done: a backup of your app.
> - Your AI assistant on the machine, as before.

## 1. Restore a copy, beside the real thing

If your backup lives somewhere else, bring the whole folder back to this machine first.

> Restore my team wiki's latest backup as a copy beside it, and tell me if it matches.

Your assistant:

- **Checks every file** of the backup against its check code first. A damaged file stops everything.
- **Starts a copy** of the app under its own name and a free port, so your real app is never touched.
- **Checks the copy:** it's running, it answers, and its data has the same fingerprint as the backup.

It reports something like "4 pages, same as the backup: pass". Open the copy's address if you like and have a look. This is a restore you can trust.

## 2. See it catch a difference

Change something in your real app, such as adding a page, and ask your assistant:

> Check my team wiki against that backup.

It says the data differs: the backup has 4 pages, the app now has 5. That's the fingerprint doing its job: it tells you whether the data in front of you is the data you saved.

## 3. Put a backup back, if you ever need to

If you lose something, this is the one that matters:

> I deleted pages from my team wiki by mistake. Put it back the way it was in last night's backup.

Because this **replaces what's there now,** your assistant asks first. Before it does anything it also makes a fresh backup of the app as it is, so you can undo the undo. Then it restores, starts the app, and checks the fingerprint, the same way as before.

## 4. Clean up the copy

When you've looked at the copy, ask your assistant to remove it:

> Remove the restored copy of my team wiki.

## What you've just done

- **You know your backup works,** because you restored it and checked it, not because it seemed to finish.
- **You can get back from a mistake,** with a safety backup taken first.
- **You've seen how to compare** an app with a backup at any time.

Restoring onto a different machine is what a move does. That's [the next chapter](../move-an-app/).

<details>
<summary>Prefer to do it by hand?</summary>

card-kit's `restore-card` and `verify-card`, from the Edgible skill. With the backup folder from chapter 1:

```bash
# a copy beside the app, under its own name and a free port
python3 ~/.card-kit/restore-card.py ~/otter-wiki-backups/<stamp> ~/otter-copy --as otter-copy --dry-run
python3 ~/.card-kit/restore-card.py ~/otter-wiki-backups/<stamp> ~/otter-copy --as otter-copy

# does the running app hold the same data as the backup?
python3 ~/.card-kit/verify-card.py ~/otter-wiki --against ~/otter-wiki-backups/<stamp>

# put the backup back over the app (asks first, backs the app up first)
python3 ~/.card-kit/restore-card.py ~/otter-wiki-backups/<stamp> ~/otter-wiki
```

Add `--dry-run` to any of them to see what it would do and change nothing. Remove a copy with `docker compose --env-file ~/otter-copy/card.env -f ~/otter-copy/docker-compose.yml down -v`.

</details>
