---
# vim: tw=80
title: IP Addresses in the Alpha API
layout: post
author: Josh Sager
avatar: https://www.linode.com/media/images/employees/jsager.png
tags:
- APIv4
---
In our latest development rollout of the Alpha API, we’ve started adding
networking capabilities, beginning with public and private IPs for your Linodes.
This means both IP types will soon be available in the
[new Linode Manager](https://github.com/Linode/manager "new Linode
Manager") sometime in the near future.

By the way, if you have not yet checked out the new Manager, please do so; the
development team working toward its implementation has been doing a phenomenal
job.

&nbsp;

## Accessing your Linode's IPs

(In this iteration, we focused on IPv4 addresses only; IPv6 will be available
in the API very soon.)

As is the case with all other endpoints, you can list your IPs with
a standard GET call:

```bash
$ curl -H "Authorization: token <my-token>" \
    -H "Content-Type: application/json"
    https://api.alpha.linode.com/v4/linodes/ips
```

For details regarding a specific IP, add the IP to the endpoint:

```bash
$ curl -H "Authorization: token <my-token>" \
    -H "Content-Type: application/json"
    https://api.alpha.linode.com/v4/linodes/ips/123.45.67.89
```

#### POSTing for IP Allocation

Because IPv4 is in short supply, typically you can only have one public
IP per Linode. We do, however, offer a POST:

```bash
$ curl -H "Authorization: token <my-token>" \
    -H "Content-Type: application/json"
    https://api.alpha.linode.com/v4/linodes/ips
    -X POST -d '{"type":"public"}'
```

Why then, you're surely asking, are we teasing you with a POST option when we only allow one public IP? Well, because
you can manually add as many private IPs as you like by changing the `type` to
"private":

```bash
    -X POST -d '{"type":"private"}'
```

(For the record, in the alpha API you can have a maximum of two public IP addresses.)

## Nodebalancer Update

As much fun as the networking component has been (I can _feel_ your excitement
oozing through the monitor from all of the CURL examples), it was also done to
support our effort to add Nodebalancers into the new API. Its implementation
has been challenging but also very rewarding, and there is still
a significant amount of work left to do. But, significant progress has been made and
we are pushing ever closer to full-on Nodebalancer greatness. Look for a
triumphant Nodebalancer release in the next few development cycles.

## Feedback

How has the API been working for you so far? Do you have any comments, suggestions, or
other feedback? We'd love to hear what your thoughts are. Please drop by
the [#linode-next channel on OFTC](https://webchat.oftc.net/?channels=linode-next&uio=d4)
and let us know what you think, and don't forget to keep an eye on our
[github](https://github.com/linode) for updates to our exciting open source
projects.
