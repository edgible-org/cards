---
icon: globe
title: Use your own domain
description: Give any app an address on a domain you own, such as links.yourname.com, without interrupting it.
prev: a-home-for-your-apps
---

# Use your own domain

*An appendix for every playbook.*

Every app gets an Edgible address, such as `https://my-agent.<you>.edgible.app`. If you own a domain, you can give any app an address on it as well, such as `links.yourname.com` or `agent.yourname.com`. The app keeps working at its Edgible address throughout.

> **What you need**
>
> - A domain you manage, at a provider such as Cloudflare, Namecheap or GoDaddy, where you can add DNS records.

## 1. Ask Claude

> Put my bookmarks on links.yourname.com.

It asks first, then gives you one record to add: a **CNAME** from `links.yourname.com` to your app's Edgible address.

## 2. Add the record

At your domain provider, add that CNAME record exactly as Claude gave it. This is the one step only you can do.

## 3. Check it

After a few minutes:

> Does links.yourname.com work yet?

Once your provider has published the record, Edgible issues the certificate for HTTPS, and the address answers. It usually takes minutes, and occasionally longer.

If you've bookmarked your apps, refresh them: *"Refresh my app bookmarks."*

## What you've just done

Your app answers at your own address, with HTTPS, on your machine, and nothing about it changed. Any app can do the same.
