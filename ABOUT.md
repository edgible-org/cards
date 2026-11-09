# About cards

Say you want a website, an editor for it, some analytics, and something that tells you when it falls over. The usual answer is a subscription for each, with your data on someone else's servers.

Run it yourself. Your data stays on a machine you own, and open-source tools don't change their price or their terms on you.

![The cards loop: get a setup working, write it down as a card, it is tested on a real machine, someone else runs it, makes it their own, and shares it back](about/loop.svg)

## A setup you can share

Most self-hosting happens alone, so the next person starts from scratch. A card is a working setup written down, so someone else can run it, change it, and share it back. Edgible gives each app its own address, and you choose who gets in: anyone, people in your organization, or callers with a key.

## What's in a card

The hard part is the whole setup: which apps go together, which address is open and which needs a sign-in, what runs on which machine, how you check it, and how you take it down. The website card is one example: the site, an editor, analytics, and an uptime monitor you can put on a second machine.

A card has nothing personal in it. Your devices and addresses stay in `card.env` on your machine, and the card makes its passwords there.

## Shaped for sharing

- **Places, not machines.** A card says "the forge" and "the runner", so you map each place to a machine you have.
- **The same shape every time.** Why, What, How, Verify, Tear down. Once you've used one, you know them all, and so does an AI assistant. [Use cards with your AI](AI.md). The [conventions](https://github.com/edgible-org/card-kit#conventions) are there if you're writing one.
- **Checks instead of trust.** `check-env` looks at your machine before you start. Verify checks each address. Tear down backs up your data before it deletes anything.
- **Tested on a real machine.** A card's badge says it still works, not just that it worked when it was written.
- **Plain files in git.** Read a card before you run it, fork it, and share a variant back.

## What it keeps and protects

Every card's page says this in the open.

- **What it keeps.** Each volume is marked: yours to back up, rebuilt by the app, or safe to lose. After a restore or a move, a count of numbers and dates shows your data arrived.
- **What it protects.** Passwords the app needs are made on your machine. They are never written into a file you share, or sent to your AI or to Edgible. The one you need, such as the admin password, is one command on that machine. Keys you bring stay in `card.env`.
- **How well the app fits.** Facts, shown on the tile: secrets kept in files, a health check, starts without root, runs on both kinds of processor.

## A person behind every card

Cards don't say whether a person or an AI wrote the app. They show who answers for the card: a steward, or that nobody does.

## Who runs this

[Stefano Picozzi](https://www.linkedin.com/in/stefanopicozzi), a co-founder of Edgible, looks after the catalog. He reads each card, runs it on the test machines, and decides what stays. To reach him, or anyone at Edgible, use [the contact form](https://www.edgible.ai/contact/).

The catalog is MIT-licensed, and a card runs on any server. Edgible's AI skill uses the same cards. Running one on Edgible is the easiest way to get it online.

## Why "cards" and not a catalog

A catalog promises that every app works, stays current, and is supported. A card is a smaller promise: someone's record of what worked for them. The app belongs to its own project, and the card points you at that project's docs. Edgible looks after the format and the tools.

## Get involved

Have a look at the [cards](README.md) and try one. Share a change back as a variant, with a name that says what's different, like `n8n-sqlite`. [CONTRIBUTING.md](CONTRIBUTING.md) explains how. Built something yourself? [Add your app](ADD-YOUR-APP.md) checks it and helps you build what a card needs.
