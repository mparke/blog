---
# vim: tw=80
title: The new, open source React.js Linode Manager
layout: post
author: Drew DeVault
avatar: https://www.linode.com/media/images/employees/ddevault.png
tags:
- Manager
- React/Redux
---

Now that we've launched the
[public alpha](https://engineering.linode.com/2016/04/12/Announcing-APIv4.html)
for our new API, we've started on our next big project: an open source
Linode Manager. After 10 years maintaining the current ColdFusion-based Linode
Manager, we've [made the
call](http://www.joelonsoftware.com/articles/fog0000000069.html) to rewrite it
from the ground up based on the new API.

The new manager uses the
[3-clause BSD license](https://github.com/linode/manager/blob/master/LICENSE)
and is based on tech like [React.js](http://facebook.github.io/react/),
[Redux](http://redux.js.org/), [Webpack](https://webpack.github.io/), and more
cool new stuff.  I firmly believe that React+Redux is the silver bullet that
will make frontend development maintainable, testable, stable, and fun to work
on. The frontend community has finally discovered functional programming and
we're in for some fun. The new manager is fast and the codebase should scale
elegantly to support all of the features of the current manager, and more.

The current status of the manager rewrite is "early". We are going to develop
this in the open and we're totally open to community contributions. You're
encouraged to help us make this manager support all of the features
you want and need. You're also entirely welcome to fork our codebase and run
your own Linode manager with some fancy unique features, or tweak it to manage
some other service, or use it as the basis of your own React projects. We're
very excited to make a large-scale React/Redux codebase available to the
community both as a reference and a resource of code.

<p style="text-align: center"> <strong><a class="btn btn-default"
href="https://github.com/Linode/manager"><i class="fa fa-github"></i> Visit
Linode/Manager on GitHub <i class="fa fa-chevron-right"></i></a></strong> </p>

It's an unusual choice to make a project like this open source. Tom
Preston-Werner (cofounder of GitHub) famously said that you should "[open source
(almost)
everything](http://tom.preston-werner.com/2011/11/22/open-source-everything.html)"
and argues that you should open source anything that isn't part of your core
business value. Most of our core business value comes from our excellent support
team and our high-performance server fleet, as well as some of the software we are keeping
proprietary, like our API and everything behind it. You could make the argument
(and some of us did during this discussion) that the manager is part of our
secret sauce - but it may be a special case. It was decided that the new manager
should be a static website that talks to the API, and at that point we're
already delivering all of the code to your browser anyway. We decided
to give you the unminified version instead and get some cool open
source cred while we're at it.

It's also a risky choice to rewrite it from the ground up. This has been a long
time coming, though. Our current architecture's design is a few generations of
best practices behind the curve. Some of the choices that were made
early on don't scale so well now - in particular the monolithic nature of it.
It's become burdensome to maintain, and when we chose to rewrite the API from the
ground up we saw an opportunity to dogfood it and pay back our manager's tech
debt. Things are going very well so far, and I believe this was the right
choice. Expect more retrospective blog posts about this choice in the future!
