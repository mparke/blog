---
# vim: tw=80
title: Announcing Linode API 4 Public Alpha
author: Drew DeVault
avatar: https://www.linode.com/media/images/employees/ddevault.png
layout: post
tags:
- APIv4
- Python/Flask
---

The Linode API was first introduced 7 years ago, and its age is showing. We
all know it could be better. So I'm happy to announce that after
months of hard work from the Linode dev team, API 4 is entering
alpha phase. We built it from the ground up with a modern
RESTful design, and I think you'll like it.

To get into the alpha, visit [alpha.linode.com](https://alpha.linode.com) and
request an invite. You can also check out our brand new [developer
hub](https://developers.linode.com), which has all of the documentation for the
new API. The developer hub is a [Jekyll](http://jekyllrb.com/) project on GitHub
Pages, and is [open source](https://github.com/Linode/developers). We're
hoping that you can help us by building libraries and tools in your favorite
languages, and contributing guides and improvements to the developer
documentation. We're also accepting bug reports, feature requests, and other
feedback via
[GitHub issues](https://github.com/Linode/developers/issues).

## At a glance

Previously, you made 4 API calls to create a living, breathing Linode. It was
pretty bad, so we streamlined it. Many of the low-level decisions
(like disk layout and boot configs) are given sane defaults. Now:

<div id="curl-example">
{% highlight bash %}
#!/bin/bash
token="a valid oauth token"
linode=$(curl -H "Content-Type: application/json" \
    -H "Authorization: token $token" \
    -X POST -d '{
        "datacenter": "datacenter_6",
        "service": "service_112",
        "source": "distro_140",
        "root_pass": "hunter2"
    }' https://api.alpha.linode.com/v4/linodes)
{% endhighlight %}
</div>

<script>
var password = Math.random().toString(36).slice(-8);
password += Math.random().toString(36).slice(-8);
var html = document.getElementById('curl-example').innerHTML;
html = html.replace("hunter2", password);
document.getElementById('curl-example').innerHTML = html;
</script>

This creates a new Linode 1024 (`service_112`) in Newark (`datacenter_6`) with
Debian 8.1 (`distro_140`) installed. The response is a [Linode
object](http://developers.linode.com/reference/#object-linodes)
as JSON. Since we're using the shell I'm going to use
[jq](https://stedolan.github.io/jq/), a command line JSON parser, to grab the ID:

{% highlight bash %}
linode_id=$(echo "$linode" | jq -r .linode.id)
{% endhighlight %}

And now we can boot it:

{% highlight bash %}
curl -H "Authorization: token $token" \
    -X POST https://api.alpha.linode.com/v4/linodes/$linode_id/boot
{% endhighlight %}

That's it! You can watch the state change to "running" as it's provisioned and
booted:

{% highlight bash %}
curl -H "Authorization: token $token" \
    https://api.alpha.linode.com/v4/linodes/$linode_id | jq .state
{% endhighlight %}

Once it's up, you can log into your new Linode.

{% highlight bash %}
linode_ip=$(echo "$linode" | jq -r .linode.ip_addresses.public.ipv4[0])
ssh root@$linode_ip
{% endhighlight %}

And while this whole process has been greatly simplified, we
haven't left power users behind. There are still API endpoints for doing
things the hard way. We currently support many of the features that are already
supported by the old API, and we're working towards supporting even more
features than that. Our goal is to support every feature of Linode via the new
API.

Additionally, we've done away with API keys in favor of OAuth tokens. OAuth has
been the hot new thing for a while now. You can now create access tokens that
allow users to offer you a fine-grained set of permissions.
When you sit down to make something with the Linode API, you'll need to first
request an [invite](https://alpha.linode.com) then register your client at [login.alpha.linode.com](https://login.alpha.linode.com).
Finally, head over to the [authentication docs](https://developers.linode.com/reference/#authentication)
to get started.

## Linode + Flask == ❤️

Curious developers who've visited our [careers](https://linode.com/careers) page
in the past may have been surprised to find ColdFusion in our stack (myself
included). Linode has been around for a long time, and what got the job done
10 years ago is rarely the best choice for tomorrow. So with maintainability and
quality in mind, we wrote the new API in Python. All of the devs here
are very excited, and the new design is really solid. API 4
uses tools like [Flask](http://flask.pocoo.org/) and [SQLAlchemy](http://www.sqlalchemy.org/)
and is delightful to work on. The new API is also stateless and easier to distribute and make
more reliable.

We've had a pretty interesting journey writing Linode's new API from scratch.
There were many challenges replacing a large, established codebase and
infrastructure. Facing these challenges gave us a chance to refine our
application design early on, before the codebase was too big to effectively
undertake large scale refactorings. I am very proud of what we've built, and we
want to share some of the innovations we've made with the open source world.

Linode's current [open source offerings](https://github.com/Linode) are pretty
sparse. This will change. I can personally see gaps in the open source world
when it comes to building things with Flask, and we have filled many of them
during our work on API 4. We have plans on pulling our work out into
independent, open-sourcable Python modules. Personally, I've got my eye on our
validation module and our lightweight SQLAlchemy ⟷ JSON module. We're also
taking a look at writing some API wrappers for the new API. These will be open
source, of course.  In fact...

## pip install linode-api

We're shipping the alpha with a brand new Python API wrapper,
[linode-api](https://pypi.python.org/pypi/linode-api)
([GitHub](https://github.com/Linode/python-linode-api)). Check it out:

{% highlight python %}
>>> from linode import LinodeClient
>>> client = LinodeClient("a valid oauth token",
...     base_url="https://api.alpha.linode.com/v4")
>>> service = client.get_services(Service.label == "Linode 1024")[0]
>>> datacenter = client.get_datacenters(Datacenter.label == "Newark, NJ")[0]
>>> distro = client.get_distributions(Distribution.label == "Ubuntu 14.04")[0]
>>> (linode, password) = client.create_linode(service, datacenter, source=distro)
>>> linode.label = "My Awesome Linode"
>>> linode.save()
{% endhighlight %}

We support server-side filtering and the Python client implements a filtering
syntax that's very similar to SQLAlchemy's syntax (the server-side
implementation of this is another candidate for open source). The Python
wrapper also includes a login.linode.com client that can help you implement an
OAuth flow - check out the [example
app](https://github.com/Linode/python-linode-api/tree/master/examples/install-on-linode).

## Engineering Blog

You may have noticed that this is not the [Linode Blog](https://blog.linode.com/),
which is a marketing tool for announcing new end-user features and such.
Following in the footsteps of several other engineering teams, we've established
a separate blog for Linode engineers to talk about the cool things we're
working on. This blog is for engineering content only - no marketing. If you're
interested in reading about the stuff we work on, subscribe to
[RSS](/feed.xml).
