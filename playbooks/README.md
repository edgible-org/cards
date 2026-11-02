# Playbooks

The AI Playbooks at [cards.edgible.org/playbooks](https://cards.edgible.org/playbooks/). Each chapter is one Markdown file here, built into a page of the cards site by card-kit's `card-site`, with the Markdown published beside it for AI assistants. `icons.svg` holds the icons the chapters draw; a chapter links to it as `../icons.svg`, and `index.md` as `icons.svg`.

A chapter starts with its title and a one-line description:

```markdown
---
title: Get Edgible running
description: Put Edgible on a machine that stays on, with your AI assistant doing the work.
prev: your-own-ai-agent
next: connect-claude
---
```

`prev:` and `next:` name the pages before and after it, by file name without `.md`; the build turns them into Previous and Next buttons at the end of the page, and stops if one names a page that doesn't exist.

How a chapter reads:

- **Prompts and links, not commands.** The reader tells their AI what they want; any command goes under a "Prefer to do it by hand?" section at the end, in a `<details>` block.
- **Keys through the key link,** never pasted into a chat or a command.
- **Plain words** for people who are comfortable with technology but not technical.
- **Ends with what you've just done:** a few lines on what the reader now has and why it matters, in plain words: honest, warm, never hype. It's the part that makes the effort feel worth it.
- **Tested.** Every prompt in a chapter has been run, and the AI regression checks that assistants follow it.

`index.md` is the list of playbooks; this README is not published.
