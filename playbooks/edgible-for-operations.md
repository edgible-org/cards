---
icon: backup
title: Edgible for Operations
description: Back it up, move it, upgrade it, and know when something is wrong, so it keeps running.
---

# Edgible for Operations

Back it up, move it, upgrade it, and know when something's wrong, so it keeps running. One playbook so far, in progress: the first three chapters are ready, and the rest are on the way. Every playbook begins with [Get Edgible running](../get-edgible-running/).

**These playbooks are for apps that run from an Edgible card,** and work best with a card that says where its data lives. If you built the app yourself, the ideas still apply, but the tools don't, and we haven't tried these steps on a hand-built app.

<figure class="flow">
<svg viewBox="0 0 420 354" role="img" aria-labelledby="map-t map-d" xmlns="http://www.w3.org/2000/svg">
<title id="map-t">Looking after it, in order</title>
<desc id="map-d">One playbook, six chapters. The first three, backing up an app, restoring it and proving it, and moving it, are ready. Upgrading has short guidance for now. Knowing when something is wrong, and recovering when the machine dies are coming.</desc>
<rect x="10" y="10" width="400" height="334" rx="16" class="frame"/>
<text x="28" y="40" class="t">Looking after it</text>
<a href="../back-up-an-app/"><rect x="24" y="54" width="372" height="40" rx="12" class="box"/><rect x="354" y="59" width="30" height="30" rx="8" fill="#111827"/><use href="../icons.svg#backup" x="357" y="62" width="24" height="24"/><circle cx="48" cy="74" r="13" class="num"/><text x="48" y="80" class="numt" text-anchor="middle">1</text><text x="72" y="80" class="t b">Back up an app</text></a>
<a href="../restore-and-prove-it/"><rect x="24" y="102" width="372" height="40" rx="12" class="box"/><rect x="354" y="107" width="30" height="30" rx="8" fill="#111827"/><use href="../icons.svg#tested" x="357" y="110" width="24" height="24"/><circle cx="48" cy="122" r="13" class="num"/><text x="48" y="128" class="numt" text-anchor="middle">2</text><text x="72" y="128" class="t b">Restore it, and prove it</text></a>
<a href="../move-an-app/"><rect x="24" y="150" width="372" height="40" rx="12" class="box"/><rect x="354" y="155" width="30" height="30" rx="8" fill="#111827"/><use href="../icons.svg#machine" x="357" y="158" width="24" height="24"/><circle cx="48" cy="170" r="13" class="num"/><text x="48" y="176" class="numt" text-anchor="middle">3</text><text x="72" y="176" class="t b">Move an app to another machine</text></a>
<a href="#upgrading-for-now"><rect x="24" y="198" width="372" height="40" rx="12" class="box opt"/><rect x="354" y="203" width="30" height="30" rx="8" fill="#111827"/><use href="../icons.svg#bolt" x="357" y="206" width="24" height="24"/><circle cx="48" cy="218" r="13" class="num"/><text x="48" y="224" class="numt" text-anchor="middle">4</text><text x="72" y="224" class="t b">Upgrade an app safely: for now</text></a>
<g opacity=".6"><rect x="24" y="246" width="372" height="40" rx="12" class="box opt"/><rect x="354" y="251" width="30" height="30" rx="8" fill="#111827"/><use href="../icons.svg#eye" x="357" y="254" width="24" height="24"/><circle cx="48" cy="266" r="13" class="num"/><text x="48" y="272" class="numt" text-anchor="middle">5</text><text x="72" y="272" class="t b">Know when something is wrong</text></g>
<g opacity=".6"><rect x="24" y="294" width="372" height="40" rx="12" class="box opt"/><rect x="354" y="299" width="30" height="30" rx="8" fill="#111827"/><use href="../icons.svg#lock" x="357" y="302" width="24" height="24"/><circle cx="48" cy="314" r="13" class="num"/><text x="48" y="320" class="numt" text-anchor="middle">6</text><text x="72" y="320" class="t b">When the machine dies</text></g>
</svg>
</figure>

The chapters:

- **<span class="ico sm" aria-hidden="true"><svg><use href="../icons.svg#backup"/></svg></span>[Looking after it](../looking-after-it/):** the unglamorous essentials of running your own apps, backed up, restored and proved.
  1. <span class="ico sm" aria-hidden="true"><svg><use href="../icons.svg#backup"/></svg></span>[Back up an app](../back-up-an-app/)
  2. <span class="ico sm" aria-hidden="true"><svg><use href="../icons.svg#tested"/></svg></span>[Restore it, and prove it](../restore-and-prove-it/)
  3. <span class="ico sm" aria-hidden="true"><svg><use href="../icons.svg#machine"/></svg></span>[Move an app to another machine](../move-an-app/)
  4. Upgrade an app safely: coming; for now, see [Upgrading, for now](#upgrading-for-now)
  5. Know when something is wrong: coming
  6. When the machine dies: coming

<h2 id="upgrading-for-now">Upgrading, for now</h2>

Every app is different, and we can't predict what an upgrade will ask of yours, so there's no fixed chapter yet. Until there is, the approach is simple, and your AI assistant can do most of it:

1. **Back it up first.** [Chapter 1](../back-up-an-app/). Its fingerprint then tells you whether your data came through.
2. **Ask your AI what the upgrade changes.** For example: "What changes if I upgrade my team wiki to the newest version? Anything that could hurt my data?" It can compare the old and new card and tell you in plain words, such as new settings, new image versions, or a database moving to a new major version.
3. **Let it recommend a path,** and ask before it acts. That may be the app's usual upgrade, or something specific to the app, such as a database's own upgrade tool. A safe way to try an upgrade is to restore your backup as a copy beside the app and upgrade the copy first ([chapters 2 and 3](../restore-and-prove-it/)). If the copy breaks, your real app is untouched, and if it works, you can switch. An upgrade can change how your data is stored, and on a copy that costs you nothing.

If the AI isn't sure, it should say so and stop, not guess. We haven't run upgrades end to end in these playbooks, and we may never write one fixed recipe, because apps differ too much.

New here? Start at [all the playbooks](../), or go straight to [Get Edgible running](../get-edgible-running/).
