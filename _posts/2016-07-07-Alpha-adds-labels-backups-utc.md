---
# vim: tw=80
title: API Alpha upgrades Plan, adds Labels, improves Backups, UTC
layout: post
author: James Ottinger
avatar: https://www.linode.com/media/images/employees/jottinger.png
tags:
- APIv4
---
We are proud to announce another round of features and improvements to the
API Alpha. With this release, we're upgrading the test Linode plan,
doing even more cool things with Backups in our API Alpha environment,
adding labels, and changing how time works. We’ve also added some
capacity to our API Alpha environment, as it keeps growing in popularity!

Let's explore the new changes in more detail:


## New Plan, More Capacity

The API Alpha environment has been upgraded with the latest Linode plan.
We are sporting a plan from [our recent Linode 13th Birthday upgrade](https://blog.linode.com/2016/06/16/linodes-13th-birthday-gifts-for-all/)
in our testing environment.  Also, we have added more capacity to support
more testers. If you haven’t signed up already, we welcome you to
[Join the Linode API Alpha](https://alpha.linode.com).

## Labels

One of the most common discussions among the API Team involves ways of
making the API easier to use. The newest addition in that pursuit is
what we’re calling "slugs", or "labels". Instead of looking up an
ID, you can use an easy-to-remember label.

In this update, we've added labels for data centers, services,
distributions, and kernels.  For example, instead of the datacenter
parameter being "datacenter_6", it can now be "newark". Likewise, a Linode
service plan is "linode2048.5". Cool, huh?

## Creating a Linode from a Backup

Today’s update also adds the ability to easily create a new Linode from a Backup.
The existing [/linodes endpoint](https://developers.linode.com/reference/#ep-linodes-methods)
has been enhanced to allow the "source"  parameter to accept a Backup ID.
Let’s take a look at an example, and use some of the new labels in the process:

{% highlight bash %}
#!/bin/bash
token="a valid oauth token"
linode=$(curl -H "Content-Type: application/json" \
    -H "Authorization: token $TOKEN" \
    -X POST -d '{
        "source": "backup_123",
        "datacenter": "newark",
        "service": "linode2048.5"
    }' \
    https://api.alpha.linode.com/v4/linodes)
{% endhighlight %}

If you are just getting started with Backups in our Alpha API environment, the full
[documentation](https://developers.linode.com/reference) includes detailed
instructions and more examples to get you going quickly.

## Coordinated Universal Time, UTC

What time is it? It is UTC Time. How about now? It’s still UTC Time. *(drops microphone)*

All API responses that include a datetime property now return that same property
in Coordinated Universal Time format. Moving to UTC removes any confusion with
dates and times.

## Feedback

If you haven't had the opportunity to leave us feedback, we invite you to
do so. If you have, we thank you for your continued support. The entire API
Alpha Team reviews all input and we love hearing from you. Head on over
to [github](https://developers.linode.com/) or talk to us in the
[#linode-next channel of OFTC](https://webchat.oftc.net/?channels=linode-next&uio=d4).

Stay tuned for more updates!