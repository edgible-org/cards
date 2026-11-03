---
icon: machine
title: Move an app to another machine
description: Move an app and its data from one computer to another, even a different kind of computer, and check that nothing was lost on the way.
prev: restore-and-prove-it
---

# Move an app to another machine

*Chapter 3 of [Looking after it](../looking-after-it/). *New: we ran this once, moving a wiki from a Mac to a Windows laptop. Other pairs of machines are still to be tried, so [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).**

Sooner or later an app outgrows its machine, or the machine goes. A move is a restore (chapter 2) onto a different computer, then a switch. The old copy keeps serving until the switch, so you can stop at any point and nothing is lost.

> **What you need**
>
> - An app that runs from an Edgible card, one whose card says where its data lives (see [Looking after it](../looking-after-it/)).
> - [Chapters 1 and 2](../back-up-an-app/) done, so you know a backup of this app restores.
> - The new machine, set up as in [Get Edgible running](../get-edgible-running/) and showing as online in Edgible. Your assistant can set it up.
> - Your AI assistant on the old machine, and on the new one. We ran it that way, with you passing the file between them.
> - A way to get the backup folder from the old machine to the new one (step 2). That part is yours.

## 1. Back up on the old machine

> Back up my team wiki, and tell me what will stop first.

It's the same backup as in [chapter 1](../back-up-an-app/). Your assistant tells you what stops and for how long, and waits for your yes. In our run, a small wiki stopped for **8 seconds**. It then reports a fingerprint of the data, for us "3 pages", which the new machine will have to match.

Ask your assistant where it put the backup, and note the full path of the folder. If you want it somewhere particular, such as an external drive, say so before it starts.

## 2. Make the backup visible to the new machine

Moving the backup between computers is up to you. Edgible writes it into a folder, and reads it back from a folder. How the folder gets from one machine to the other is your choice, and your assistant can help if you ask: an external drive, a shared network folder, or any way you already move files. Two rules:

- **Bring the whole folder.** It has a list of every file in it, and a restore checks them all. A damaged or incomplete copy is caught before anything changes.
- **Keep it private.** The backup holds the app's settings and its passwords and keys, so don't put it anywhere other people can read it.

On the new machine, note where the folder now is. That is what you tell your assistant in the next step.

*What we did:* the Mac and the Windows laptop were on the same network, so we packed the folder into one file, shared it for a few minutes, fetched it on the other side, checked it was identical, and shut the share down. Do whatever suits you.

## 3. Restore it on the new machine

> Restore the backup in this folder on this machine as my team wiki, and tell me if it matches.

Your assistant checks every file, loads the data, starts the app, and compares the fingerprint with the backup's: "3 pages, same as the backup: pass". The old machine is still serving the real app, so nothing has changed for anyone yet.

Three things to expect when the machines are different:

- **The processor can differ.** Our Mac has an Apple chip and the Windows laptop an Intel-style one. The wiki ran on both, because its image supports both. Your assistant checks this when it starts the app, and tells you if an app won't run on the new machine.
- **The app's settings name the old machine.** Your assistant changes the device name in the settings to the new one before publishing.
- **Your logins and keys come across unchanged,** so people stay signed in and nothing needs resetting. If you think the old machine or the backup may have been exposed, tell your assistant, and it can replace the app's keys instead; people then sign in again. We haven't tried that part.

## 4. Switch

This is the only step where your app is down. Ask first:

> Switch my team wiki to the new machine. Tell me when it's down and when it's back.

Your assistant removes the app's address on the old machine, publishes it from the new one, and waits until the address answers. In our run that took about a minute and a half. The address stays the same, so bookmarks and links keep working.

## 5. Check it, as a person

Open the address, sign in, and look. We checked three things, and so should you:

- **Your pages are there,** with the text you wrote.
- **Your account still works,** with the same password. Accounts live in the app's data, so they move with it.
- **The sign-in in front of the app** is still the one you chose.

If anything is missing, don't delete anything on the old machine. Its data and the backup are untouched by the move, and we didn't need to go back, so putting the app back there is untried.

## 6. Retire the old copy, later

Keep the old machine's copy of the data and the backup for a few days. When you're sure, ask your assistant to remove them, and tell it to ask before each deletion.

## What you've just done

- **You moved an app and its data** to a different kind of computer.
- **You proved it** with a fingerprint and a look, not by hoping.
- **You kept the way back** open until you were sure.

<details>
<summary>Prefer to do it by hand?</summary>

card-kit's `backup-card`, `restore-card` and `verify-card`, from the Edgible skill. On the old machine:

```bash
python3 backup-card.py ~/otter-wiki --dry-run
python3 backup-card.py ~/otter-wiki                       # writes ~/otter-wiki-backups/<stamp>/
# or: python3 backup-card.py ~/otter-wiki --to /path/to/a/folder
```

Get that whole folder to the new machine however you like. Then, there:

```bash
python3 restore-card.py <path to the backup folder> ~/otter-wiki --dry-run
python3 restore-card.py <path to the backup folder> ~/otter-wiki --yes
sed -i 's/^DEVICE=.*/DEVICE=<new device name>/' ~/otter-wiki/card.env
```

Then publish with the card's README (the Publish step), after `edgible app delete otter-wiki --yes` on the old side.

Snags we hit, so you don't have to:

- **A folder packed on a Mac** (for example with `tar`) includes hidden `._` files. Delete them from the unpacked copy (`find <folder> -name '._*' -delete`) before restoring, or pack with `COPYFILE_DISABLE=1 tar …`.
- **Run the restore as your own user** when you can, not with `sudo`. If you used `sudo`, run `sudo chown -R "$USER": ~/otter-wiki` afterwards, or the Publish step can't read `card.env`.

</details>
