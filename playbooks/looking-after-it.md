---
icon: backup
title: Looking after it
description: A playbook for the unglamorous essentials of running your own apps: backing them up, restoring them and proving it worked, and, soon, moving, upgrading and recovering.
next: back-up-an-app
---

# Looking after it

*In progress: two chapters so far, more on the way. The tools are tested on our own machines, and the prompts are still being run end to end, so [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).*

Running your own apps means you are the one who looks after them. That's not hard, but it is the part nobody shows you. This playbook is that part, in the same way as the others: you tell your AI assistant what you want, and it does the technical work, asking before anything risky.

- **Back it up,** so a dead disk or a mistake doesn't lose anything.
- **Restore it, and prove it worked.** A backup you haven't restored is a hope. You'll restore one beside the running app and check that it holds the same data.
- **Move an app to another machine,** even a different kind of computer, and check nothing was lost.
- **Soon:** upgrade it safely, know when something is wrong, and what to do when the machine dies.

## The road map

| | Chapter | You end up with |
| --- | --- | --- |
| 1 | [Back up an app](../back-up-an-app/) | A backup of an app and its data, and a plain account of what stopped and for how long |
| 2 | [Restore it, and prove it](../restore-and-prove-it/) | A copy restored from the backup, checked against it, and the way back if you ever need one |
| 3 | [Move an app to another machine](../move-an-app/) | An app and its data on a different machine, checked against a fingerprint, with the old copy kept until you're sure |
| 4 | Upgrade an app safely | *Coming*; for now, back up first and ask your AI what the upgrade changes (see [Edgible for Operations](../edgible-for-operations/#upgrading-for-now)) |
| 5 | Know when something is wrong | *Coming* |
| 6 | When the machine dies | *Coming* |

## What you'll need

- **[Get Edgible running](../get-edgible-running/) done,** and at least one app running from a card on a machine of yours.
- **An AI assistant that can run commands on that machine,** such as Claude Code, with the Edgible skill, as in the first chapter.
- **Room for the backup:** a few megabytes for a small app, more for photos. Your assistant checks first.

One honest limit: the backup tools work on apps whose card describes where their data lives (its `data:` section). Around half of the catalog's cards do, and more are being added. For one that doesn't yet, your assistant does the same job by hand, and says so.
