---
title: Redesigning Endpoints, Creating Linodes with Backup Service, and Rebuilding Linodes
layout: post
author: Josh Sager
avatar: https://www.linode.com/media/images/employees/jsager.png
---
It's interesting how some of the biggest challenges we sometimes face as programmers
have nothing to do with programming. Creating great products takes us beyond
the ones and zeros and requires us to think more like "normal" people.
_How_ will it be used? How can we make it _better_? Can we solve the age-old problem
of making a product easier for our customers and still maintain good design principles
at the same time?

### Redesigning Endpoints

For several weeks we had numerous discussions over endpoints. As we started
interfacing the API with our new Manager, it became clear that having all of
our endpoints as a part of the top-level namespace was inelegant and
needed to change. Inconsistencies in our naming conventions were also
tripping us up a bit, so we decided to take the time now to tighten things up and iron out
problems... sooner rather than later.

The solution was to create endpoint groups, which afforded us better organization and
some layers of separation amongst our product lines, services, and utilities.
Programmatically they do not do much, but as an interface they are much
cleaner. While I won't detail every endpoint change (you can [view our
documentation](https://developers.linode.com/reference/) for the specifics),
here are the overarching highlights:


* The `/linodes` namespace has changed to `/linode/instances`
* `/stackscripts` has become `/linode/stackscripts`
* `/distributions` can be found at `/linode/distributions`
* `/kernels` has a new home here: `/linode/kernels`
* `/dnszones` is now `/dns/zones`

There are more changes to come, more endpoints that we'll be refactoring, and certainly new
endpoints for parity and feature rollouts, but we could only do so many in an
interation and wanted to focus on the most prominent first.

### Creating Linodes With Backup Service Enabled

One small oversight from past API development cycles was, admittedly, the omission of logic to enable
the Backup Service upon creation of a Linode. We recitifed that, and you can now
enable the service by using the `with_backup` attribute:

```
$ curl -X POST \
    -H "Authorization: token $TOKEN" \
    -H "Content-Type: application/json" \
        https://api.alpha.linode.com/v4/linode/instances \
            -d '{"with_backup":"true","datacenter":"newark","service":"linode2048.5"}'
```

### Rebuilding a Linode

Another feature added is the ability to rebuild your Linode. Syntax is
straightforward:

```
$ curl -X POST \
    -H "Authorization: token $TOKEN" \
    -H "Content-Type: application/json" \
        https://api.alpha.linode.com/v4/linode/instances/123456/rebuild \
        -d '{"distribution":"linode/debian8","root_pass":"abc123"}'
```

What's next on our list? Finishing NodeBalancer support is still
a high priority, as well as completing IP address support. We will
continue the refactoring and addition of endpoints as well, so look for
those, too.

Your feedback has been very helpful to us, so keep it coming. Don't forget to stop by
[#linode-next on oftc](https://webchat.oftc.net/?channels=linode-next&uio=d4)
to let us know how it's going, and stay tuned at our [github](https://github.com/linode)
for updates to our open-source projects.
