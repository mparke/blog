---
title: Networking Endpoints
author: Josh Sager
avatar: https://www.linode.com/media/images/employees/jsager.png
layout: post
---

Happy Holidays, everyone! The season of cheer has officially begun, and
nothing says peace, love, and good tidings more than unraveling the
wonderful world of IP addresses and networking.

For the past few weeks we've been chipping away at how to best organize
IP information, not only as it relates to Linodes, but
also trying to foster an environment that future-proofs the API for
features we want to add later.

It became clear that maintaining IP information strictly within the
confines of the `/linodes/instances` endpoint wouldn't be sufficient.
Moving all IP functionality presented a challenge for us, however,
since things like private IPs belong with their corresponding Linode.
We think we did a good job of cleaning it all up, though.

### Retrieving IP Collections, Allocating Public IPs

Two new endpoints have been created for returning collections of
public IPv4 addresses and IPv6 pools:

* `GET /networking/ipv4`
* `GET /networking/ipv6`

You can query a specific address by adding it to the call:

```
$ curl -X GET \
    https://api.alpha.linode.com/v4/networking/ipv4/123.44.55.66'
```

POSTing to the IPv4 endpoint allocates a new public IP to a
Linode:

```
$ curl -X POST \
    -H "Authorization: token $TOKEN" \
    -H "Content-Type: application/json" \
        https://api.alpha.linode.com/v4/networking/ipv4 \
          -d '{ "linode_id": 123456 }'
```

### Private IPs

While the new `/networking` endpoint is a welcome addition to the API,
some IP information is still located in the original
`/linode/instances` endpoint. For example, to see the private IPs
associated with a Linode:

```
$ curl -X GET \
    https://api.alpha.linode.com/v4/linode/instances/123456/ips
```

This endpoint will also return your IPv6 pools.

You can create a new private IPv4 by POSTing to this endpoint:

```
$ curl -X POST \
    -H "Authorization: token $TOKEN" \
    -H "Content-Type: application/json" \
        https://api.alpha.linode.com/v4/linode/instances/123456/ips
```

Lastly, you can reset RDNS on slaac addresses with a PUT:

```
$ curl -X PUT \
    -H "Authorization: token $TOKEN" \
    -H "Content-Type: application/json" \
        https://api.alpha.linode.com/v4/linode/instances/123456/ips/2a01:7e00::f03c:91ff:fe96:46b2 \
             -d '{ "rdns": null }'
```



### RDNS

The ability to reset RDNS is pretty straightforward with the use of a
simple `PUT` command:

```
$ curl -X PUT \
    -H "Authorization: token $TOKEN" \
    -H "Content-Type: application/json" \
        https://api.alpha.linode.com/v4/networking/ipv4/123.44.55.66' \
            -d '{ "rdns": "lavilla.strangiato.com" }'
```

To reset RDNS, simply pass in a _null_ value: `{ "rdns": null }`

### IP-Assign
Assigning an IPv4 to a Linode ("swapping" in the current
API) has a few requirements:

* You must, obviously, be the owner of both the IPv4 and the Linode you
wish to assign it to
* The IP and Linode must reside in the same datacenter
* The Linode your IPv4 is moving _from_ must have at least one public
IPv4 remaining after the assignment

Here is the syntax for assigning IPs to Linodes:

```
$ curl -X POST \
    -H "Authorization: token $TOKEN" \
    -H "Content-Type: application/json" \
        https://api.alpha.linode.com/v4/networking/ip-assign \
          -d '{ "datacenter":"newark",
                "assignments": [ \
                  { "address":"210.111.22.95","linode-id": 134504 },
                  { "address":"190.12.207.11","linode-id": 119034 },
                ]
              }'
```

## So You Don't Think We Are Only Doing IP Stuff...

We did manage to squeeze in a small change to backups, where now we are
only returning backups that are available to you for use. We felt that
returning all of the backup objects was taking a bit too long and giving
you information that wasn't incredibly helpful, and we hope the change
makes your lives just a little bit easier.


## Let Us Know What You Think

As always, thank you for your continued support and feedback.  In addition to the usual channels -
[#linode-next on oftc](https://webchat.oftc.net/?channels=linode-next&uio=d4)
and on [github](https://github.com/linode/developers) - you can send us feedback directly through the API.  POST
your thoughts to `https://api.alpha.linode.com/v4/feedback` (requires a token) with a body like `{"message": "you guys rock!"}`.
