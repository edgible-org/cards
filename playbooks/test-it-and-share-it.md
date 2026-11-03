---
icon: share
title: Test it and share it
description: Test your card on your own Edgible, open a pull request, and see it listed with who looks after it, so anyone can run your app.
prev: make-your-app-a-card
---

# Test it and share it

*Chapter 2 of [Edgible for Contributors](../edgible-for-contributors/). *New: the prompts are still being run end to end, so [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).**

Before a card reaches the catalog, it's tested on your own Edgible. Then it goes to us as a pull request, we test it again, and it's listed for everyone.

> **What you need**
>
> - The card from [Make your app a card](../make-your-app-a-card/).
> - Edgible on a machine of yours, where the test runs. A spare computer or a small virtual machine will do. Nothing of ours is touched.
> - A GitHub account, for the pull request.

## 1. Test it on your own Edgible

> Test my card end to end.

Your assistant runs the card's whole life on your machine: check, start, publish, verify, and tear down, the same test our nightly run uses. It shows you the result. If something fails, it fixes it and tests again. The result is saved with the card, and goes into your pull request.

## 2. Decide who answers for it

Every card shows who looks after it. Put your GitHub name on yours and it says **Stewarded by you**: you review changes to it, and fix it if its test fails.

Prefer not to? It can be listed with **No steward**. It's still tested every night, and if its test fails, it's shown dimmed until it passes.

## 3. Open the pull request

> Share my card: open a pull request to the Edgible cards.

It asks you first, as it does for anything that leaves your machine. Then it opens the pull request from your own copy of the cards, with the test result in it. Read what it wrote: you're the one asking for it to be listed.

## 4. What happens next

A person at Edgible reads the card and tests it again on our own machines. That's done by hand, so it isn't instant. Once it's merged, it's listed, and the nightly test keeps checking it.

## What you've just done

- **Anyone can run your app now,** with one prompt to their AI, on a machine of their own.
- **It's tested every night,** and when it breaks, someone hears about it.
- **It's still yours:** your app, your licence, your repository. The card only says how to run it.

Stuck, or not sure it's ready? [Open an issue](https://github.com/edgible-org/cards/issues/new) with what you built and where you got to, or write to us on the [contact page](https://www.edgible.ai/contact/).

<details>
<summary>Prefer to do it by hand?</summary>

The test is card-kit's `test-card`, run on the machine with Edgible, from a clone of your fork of [edgible-org/cards](https://github.com/edgible-org/cards) with card-kit beside it:

```bash
python3 ../card-kit/test-card.py <name> --device <your-device>
../card-kit/run check-cards --fresh
```

Then commit the card with the `test.yml` it wrote, and open the pull request from your fork. The [contributing guide](https://github.com/edgible-org/cards/blob/main/CONTRIBUTING.md#add-a-card) has every step.

</details>
