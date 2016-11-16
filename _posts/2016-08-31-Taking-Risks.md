---
title: Taking Risks - API Labels and Prefixes Rollback
layout: post
author: Will Smith
avatar: https://www.linode.com/media/images/employees/wsmith.png
tags:
- APIv4
---
Part of the intention behind development of the Linode API v4 Public Alpha 
has been to try new
ideas and get feedback before customers are dependant on the API for their
day-to-day work. This gives us the freedom to take risks we would
otherwise shy away from without fear of long-term consequences if
they didn't pan out. If we didn't end up rolling back at least once experimental
feature, we would have missed the whole point and I wouldn't be writing a blog post
like this.  But we took a risk - and missed. So, with a heavy heart,
I must announce a rollback and confirm that we have removed "labels" from most
endpoints in the API.

### Label Trouble

[Last time](https://engineering.linode.com/2016/07/26/Labels-Rollout.html) I wrote
our blog post, we were proudly rolling out labels to most API endpoints. The idea was
as simple as it was elegant - in place of meaningless numeric identifiers, use
the "label" property (or equivalent) of the object as it's unique identifier. It
resulted in very digestible URLs like these:

```
https://api.alpha.linode.com/v4/linodes/example
https://api.alpha.linode.com/v4/dnszones/example.org
https://api.alpha.linode.com/v4/distributions/linode/ubuntu15.10
```

The concept wasn't without issue, however; many resources don't require labels
to be unique, and while it made lots of sense for some endpoints (Linodes, DNSZones, Distributions),
others were more of a stretch (Disks, Linode Configs, Backups). This was complicated by
verbose, automatic labels given to resources like Disks and Configs, making URLs
much less elegant.  We were also able to identify a slew of edge cases that would create
collisions or confusion no matter how we approached them.

We discussed rule-making options for when labels would or would not be supported, and
came up with the following:

*A resource's identifier will be a label if the resource's label does not commonly change,
is controlled by Linode, and if the resource is public.*

This rule helps keep labels in some of the most useful places, while avoiding all of the
complications that labels can create.  The following resources retain their labels:

 * Services
 * Datacenters
 * Distributions
 * Kernels

This rule still gives you the very clean deployment code (example uses the
[python library](https://github.com/linode/python-linode-api)):

```python3
client = linode.LinodeClient(my_token)
linode = client.create_linode('linode2048.5', 'newark', source='linode/ubuntu15.10')
```

### Identity Types

As a consequence of rolling back labels, we've also changed the type of identifiers for objects that are not
labelled.  Previously, we used prefixed IDs, like "linode_123".  While the built-in type information
allowed you to do 
[cool things](https://github.com/linode/python-linode-api/blob/1425dd22c07b19d21f78696d4c1c855450dce911/linode/mappings.py#L29),
it wasn't actually useful in most cases, and most people we talked to wanted a simple `int` instead
of a string.  Now, IDs of objects that don't have labels will be `ints`.  For example, the three URLs
above become this:

```
https://api.alpha.linode.com/v4/linodes/123
https://api.alpha.linode.com/v4/dnszones/456
https://api.alpha.linode.com/v4/distributions/linode/ubuntu15.10
```

Likewise, a Linode object might look like this:

```json
{
  ...
  "datacenter": {
    "country": "us",
    "id": "newark",
    "label": "Newark"
  },
  "distribution": null,
  "group": "demo",
  "id": 123,
  "ips": {
    "private": {
      "ipv4": [],
      "link_local": "fe80::f03c:91ff:fe96:46f5"
    },
    "public": {
      "failover": [],
      "ipv4": [
        "172.28.4.8"
      ],
      "ipv6": "2a01:7e00::f03c:91ff:fe96:46f5"
    }
  },
  "label": "example",
  "services": [
    {
      "hourly_price": 1,
      "id": "linode2048.5",
      "label": "Linode 1024",
      "mbits_out": 125,
      "monthly_price": 1000,
      "ram": 1024,
      "service_type": "linode",
      "storage": 24,
      "transfer": 2000,
      "vcpus": 1
    }
  ],
  "state": "provisioning",
  ...
}
```

### Networking, Nodebalancers, etc.

In this deployment we're also expanding the `/linodes/:id/ips` response to include
IPv6 information; it now looks like this:

```json
{
    "ipv4": [
        {
            "address": "172.28.4.8",
            "id": 201414,
            "rdns": "li1-8.members.linode.com",
            "type": "public"
        }
    ],
    "ipv6": [
        {
            "range": "2a01:7e00::f03c:91ff:fe96:46f5/64",
            "type": "public"
        },
        {
            "range": "fe80::f03c:91ff:fe96:46f5/64",
            "type": "private"
        }
    ]
}
```

We've also continued down the path of Nodebalancer support, which should be ready for tinkering
in the near future.

As always, thanks for your continued support and feedback.  Don't forget to stop by 
[#linode-next on oftc](https://webchat.oftc.net/?channels=linode-next&uio=d4)
to let us know how it's going, and stay tuned at our [github](https://github.com/linode)
for updates to our open-source projects.
