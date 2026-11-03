---
icon: cube
title: Make your app a card
description: Your AI assistant checks your app, tells you what a card needs, builds what's missing, and writes the card.
prev: edgible-for-contributors
next: test-it-and-share-it
---

# Make your app a card

*Chapter 1 of [Edgible for Contributors](../edgible-for-contributors/). *New: the prompts are still being run end to end, so [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).**

A card is a few plain files that say how to run your app: its image, its settings, and where its data lives. This chapter makes one, with your AI doing the writing.

> **What you need**
>
> - Edgible running on a computer of yours, with your AI assistant and the Edgible skill. If not, start with [Get Edgible running](../get-edgible-running/).
> - Your app, in a repository or a folder your AI can read.

## 1. Tell your AI about your app

In your AI assistant:

> I built an app at (your repository or folder). Help me turn it into an Edgible card.

It reads your app and tells you, in plain words, what a card needs and what your app is missing. It changes nothing in your app without asking.

## 2. What a card needs

Your assistant checks these for you. They're here so you know what it's looking for.

**Required**

- A public image with a version tag, built for both Intel and Apple Silicon
- A licence that lets others run it
- Its settings written down
- Its port, and where its data lives
- No secrets in the code
- Someone who answers for it: a GitHub name

**Nice to have**

- A healthcheck
- Not running as root
- Secrets that can come from files
- A note on how to back it up
- An icon: a square logo, which your AI can draw for you. Without one, the catalog shows the Edgible symbol
- Tagged releases
- No default password in the files

## 3. Fix what's missing

> Build what's missing, one piece at a time, and ask me before each change.

It offers to build each missing piece, such as an image for both kinds of computer, or a setting read from a file instead of the code. You make the calls. Two are yours alone: the licence, and who answers for the card.

**No image yet?** Most apps people build don't have one, and a card needs one: a packaged copy of your app that anyone can download and run. Your AI sets up GitHub to build it for you, under your own name, each time you tag a release:

> My app has no image yet. Set up GitHub to build one.

It adds one file to your repository, asks you before it pushes anything, and checks the result. After that, a new version is just a new tag.

## 4. Let it write the card

> Write the card for my app.

It writes the card's files: what to run, the settings with your own values left out, where the data lives, and a README. It checks them again until nothing required is missing.

## What you've just done

- **Your app is written down,** in a form anyone can read and run, with nothing of yours in it.
- **It's still only on your machine.** Nothing has been shared yet.

Before anyone else runs it, it's tested. [Test it and share it](../test-it-and-share-it/) is the next chapter.

<details>
<summary>Prefer to do it by hand?</summary>

Your assistant runs card-kit's `check-app`, which comes with the Edgible skill:

```bash
python3 ~/.card-kit/check-app.py <your app's folder> --image <name:tag> --steward <your GitHub name>
```

It lists what is required and what is nice to have, and says which are missing. To write the card yourself, copy the card closest to yours in [edgible-org/cards](https://github.com/edgible-org/cards) and follow the [contributing guide](https://github.com/edgible-org/cards/blob/main/CONTRIBUTING.md#add-a-card).

</details>
