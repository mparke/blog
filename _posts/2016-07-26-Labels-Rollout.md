---
# vim: tw=80
title: API Alpha Label Rollout
layout: post
author: William Smith
avatar: https://www.linode.com/media/images/employees/wsmith.png
tags:
- APIv4
---
After two more weeks of brain power and coffee, we have another fresh batch of
updates for the API V4 Alpha!  This time around we've put a lot of effort into
rolling out labels for the majority of resources that didn't use them, as well as
some bug fixes and assorted improvements.  We've also laid the foundation for
upcoming features.

&nbsp;


## Labels as Identifiers

Last time, we introduced labels as the identifier for Datacenters,
Distributions, Services, and Kernels.  This time, we're leaping forward by rolling
out labels for all Linode and DNS related resources - check it out:

```bash
$ curl -H "Authorization: token <my-token>" \
    https://api.alpha.linode.com/v4/linodes/my-webapp
```

For a Linode and its Disks and Configs, the identifier is the "label" attribute
of the resource, so you can set them up on creation:

```bash
$ curl -X POST \
    -H "Authorization: token <my-token>" \
    -H "Content-Type: application/json" \
    https://api.alpha.linode.com/v4/linodes \
    -d '{"service":"linode2048.5","datacenter":"newark","source":"linode/ubuntu15","label":"new-site"}'
```

and without even looking at the response, you know where to find the new Linode:

```bash
$ curl -H "Authorization: token <my-token>" \
    https://api.alpha.linode.com/v4/linodes/new-site
```

DNSZones use their zone as their identifier, so querying them is very intuitive:

```bash
$ curl -H "Authorization: token <my-token>" \
    https://api.alpha.linode.com/v4/dnszones/example.org/records
```

The last resources to get labels will be Backups and StackScripts, coming soon.

## Better Error Messages

Previously, when POSTing or PUTing data, if anything sent in failed validation we
sent back an error message *and* a field attribute for that error, so you could
easily identify what you sent that didn't work.  We've now improved upon that
with `field_crumbs` coming back in relevant errors.  Field crumbs give a full
path to the attribute that didn't validate if that attribute is nested, making
it much easier to identify and correct problems (or present them to an end
user).

## Assorted Cleanup

We've also given the API a cleanup pass, unifying the language of some concepts
(like storage), fixing some visual issues with this blog, and fixing a few bugs
that have come up along the way.

## Feedback

With the push toward labels nearly complete, we'd love to hear what your
thoughts are on it, as  well as any suggestions you may have.  Please drop by
the [#linode-next channel on OFTC](https://webchat.oftc.net/?channels=linode-next&uio=d4)
and let us know what you think, and don't forget to keep an eye on our
[github](https://github.com/linode) for updates to our exciting open source
projects.

Thanks for checking in, next up: NodeBalancers and Networking.
