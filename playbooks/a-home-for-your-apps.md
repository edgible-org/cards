---
icon: home
title: A home for everything you've built
description: Your agent sets you up your own bookmarks app, and every app you've built goes into it, one tap away on your phone and in every browser.
prev: run-it-from-your-phone
next: take-it-all-down
---

# A home for everything you've built

*Chapter 6 of [Your own AI agent, from anywhere](../your-own-ai-agent/), the finishing touch. New: tested on our own machines, so [tell us how it goes](mailto:stefano@edgible.com?subject=Playbook%20feedback).*

By now you have several apps, each with its own address. This chapter gives them a home: your own bookmarks app, set up by your agent, with every app you've built already in it.

The app is **linkding**, a small, fast bookmark manager. It works in any browser, has browser extensions, and keeps your bookmarks on your machine instead of in one browser company's sync.

## 1. Ask your agent to set it up

In your agent, on your computer or your phone:

> Set me up somewhere to keep my bookmarks.

It suggests linkding, says why, and asks before it sets anything up. It also asks you to confirm that linkding's address is open to anyone: say yes. Linkding has its own sign-in, and only you will have the password; that's also what lets its browser extension and phone apps reach it. At the end, it gives you linkding's address and a one-time password.

## 2. Sign in, and make it yours

Open the address, and sign in as **admin** with that password. Then change the password straight away, under **Settings**. Keep it safe: the one you were given isn't shown again. On a phone, watch for the keyboard capitalising the first letter.

## 3. Let Claude bookmark your apps

Linkding needs to let Claude add bookmarks. In linkding, open **Settings**, then **Integrations**, and copy the **REST API** token. Then switch to Claude, on your phone or computer. Keys always go through Claude, your owner's view, never into your agent's chat:

> Bookmark my apps in linkding.

Claude gives you a key link: paste the token there, not in the chat. Then it adds a bookmark for each app you visit, tagged **edgible**: your agent, your gateway's admin, the connector's sign-in page, and linkding itself. The addresses meant for apps rather than people stay out, so the list stays useful.

## 4. Bookmark something of your own

Save your first bookmark of your own: your agent's address is a good one. Then, any time you add apps:

> Refresh my app bookmarks.

New apps appear. If you've removed one, Claude tells you its bookmark is out of date, and leaves you to delete it.

## What you've just done

- **Your agent built you an app.** You asked in plain words, it chose a tested recipe, asked first, and set it up on your machine.
- **Everything you've built is one tap away,** on your phone and in every browser, under the **edgible** tag.
- **Your bookmarks are yours,** on your machine, not in a browser company's account.

From here, every app you add gets a home too.

Want nicer addresses, such as `links.yourname.com`? See [Use your own domain](../use-your-own-domain/). Curious what you've just built, and how it's kept safe? Read [Under the hood](../under-the-hood/).

<details>
<summary>Prefer to do it by hand?</summary>

Linkding is the [linkding card](https://github.com/edgible-org/cards/tree/main/linkding): its README has every step. Add each app's address as a bookmark with the tag `edgible`; your Edgible console lists them all.

</details>
