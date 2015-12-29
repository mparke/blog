---
# vim: tw=80
title: Announcing Linode API 2 & Engineering Blog
author: Drew DeVault
avatar: https://www.linode.com/media/images/employees/ddevault.png
layout: post
---

The Linode API was first introduced 7 years ago, and it's showing its age. We
all know it could be a lot better. However, I'm happy to announce that after
months of hard work from the dev team here at Linode, API 2 is entering the
alpha phase. We've redesigned it from the ground up with a much more modern
RESTful design, and I think you'll like it.

To get into the alpha, visit [alpha.linode.com](https://alpha.linode.com) and
request an invite. You can also check out our brand new [developer
hub](https://developers.linode.com), which has all of the documentation for the
new API. The developer hub is a [Jekyll](http://jekyllrb.com/) project on GitHub
Pages, and is open source:
[github.com/Linode/developers](https://github.com/Linode/developers). We're
hoping that you can help us by building libraries and tools in your favorite
languages, and contributing guides and improvements to the developer
documentation. We're also accepting bug reports, feature requests, and other
feedback in the form of
[GitHub issues](https://github.com/Linode/developers/issues) on the same
repository.

## At a glance

Previously, it required 4 API calls to create a living, breathing Linode. That's
pretty bad. We've streamlined it quite a bit. Now:

<div id="curl-example">
{% highlight bash %}
#!/bin/bash
token="a valid oauth token"
resp=$(curl -H "Content-Type: application/json" \
    -H "Authorization: token $token" \
    -X POST -d '{
        "datacenter": "dctr_6",
        "service": "serv_112",
        "source": "dist_140",
        "root_pass": "hunter2"
    }' https://api.alpha.linode.com/v2/linodes)
{% endhighlight %}
</div>

<script>
var password = Math.random().toString(36).slice(-8);
password += Math.random().toString(36).slice(-8);
var html = document.getElementById('curl-example').innerHTML;
html = html.replace("hunter2", password);
document.getElementById('curl-example').innerHTML = html;
</script>

This creates a new Linode 1024 (`serv_112`) in Newark (`dctr_6`) with Debian
(`dist_140`) installed. All of the low-level decisions we used to ask you to make
about things like disk layout and boot configs are now given sane defaults. We
haven't left power users behind, though, there are still API endpoints for doing
it the hard way. The response is a Linode object
as JSON.  Since we're using the shell, I'm going to use
[jq](https://stedolan.github.io/jq/) to grab the ID:

{% highlight bash %}
linode_id=$(echo "$resp" | jq -r .linode.id)
{% endhighlight %}

And now we can boot it:

{% highlight bash %}
curl -H "Content-Type: application/json" \
    -H "Authorization: token $token" \
    -X POST https://api.alpha.linode.com/v2/linodes/$linode_id/boot
{% endhighlight %}

That's it! Wait a few seconds for the
[jobs to complete](https://developers.linode.com/reference/#ep-linodes),
and log into your new Linode:

{% highlight bash %}
linode_ip=$(echo "$resp" | jq -r .linode.ip_addresses.public.ipv4[0])
ssh root@$linode_ip
{% endhighlight %}

We've done away with API keys in favor of OAuth tokens. OAuth has been the hot
new thing for a while now. This lets you make applications that your users can
log into with their Linode account to get access to only the things you need.
When you sit down to make something with the Linode API, you need to register
your client at [login.alpha.linode.com](https://login.alpha.linode.com) (you'll
have to have an invite first). Then you can head over to the
[authentication docs](https://developers.linode.com/reference/#authentication)
to get started.

## Linode + Flask == ❤️

Curious developers who've visited our [careers](https://linode.com/careers) page
in the past may have been surprised to find ColdFusion in our stack (myself
included). Unfortunately, many of them probably stopped reading after that
(myself excluded). Linode has been around for a long time, and we all know how
codebases tend to look after over a decade of use. The new API, however, is
written in Python! All of the devs here are happy to be moving to Python, and
the new design is really solid. API 2 uses tools like
[Flask](http://flask.pocoo.org/) and [SQLAlchemy](http://www.sqlalchemy.org/)
and is delightful to work on. It's also a lot easier to avoid and mitigate
security issues on a fresh Python codebase than on a 13 year-old ColdFusion
codebase. The new API is also stateless and easier to distribute and make
more reliable.

As we've been writing Linode's new API from scratch, we've had a pretty
interesting journey. Having a large, established set of codebases and
infrastructure in place gave us a lot of challenges upfront. I consider this a
positive thing, because it gave us a chance to refine our application design
early on, before the codebase was too big to effectively undertake large scale
refactorings. I'm proud of what we've come up with as a result, and we want to
share some of the innovations we've made with the rest of the world.

Linode's current [open source offerings](https://github.com/Linode) are pretty
poor. I'm committed to fixing that, as a pretty prolific open source advocate
myself. I can personally see some gaps in the open source world when it comes to
building things with Flask, and we have filled many of them during our work on
API 2. We have plans on pulling our work out into independent, open-sourcable
Python modules. I've got my eye on our validation module and our lightweight
SQLAlchemy ⟷ JSON module. We're also taking a look at writing some API wrappers
for the new API. These will be open source, of course.

## Engineering Blog

You may have noticed that this is not the [Linode Blog](https://blog.linode.com/),
which is a marketing tool for announcing new end-user features and such.
Following in the footsteps of several other engineering teams, we've established
a seperate blog for Linode engineers to talk about all the cool things we're
working on. This blog is just for engineering content - no marketing. If you're
interested in reading about the stuff we work on, subscribe to
[RSS](http://localhost:4000/feed.xml) or just keep an eye on Hacker News (gotta
get that sweet karma somehow).
