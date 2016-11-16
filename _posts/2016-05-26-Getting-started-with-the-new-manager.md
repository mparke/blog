---
# vim: tw=80
title: Getting started with the new Manager
author: Phil Eaton
avatar: https://www.linode.com/media/images/employees/peaton.png
layout: post
tags:
- Manager
---

As you may have [seen](https://engineering.linode.com/2016/05/16/Announcing-the-new-open-source-manager.html),
the new Linode Manager is an entirely static app being developed in the
[open](https://github.com/linode/manager) on Github. This post will walk you
through the steps required to get the new Manager up and running on your local
machine. This process can also be extended to building any application on the
new API.

Note: the Manager is in its infancy. During this time, pages may be broken,
incomplete, and have no relation to the final product.

Before you begin, you must have an account on our [Alpha](https://alpha.linode.com/)
service. Once you are logged-in to the Alpha [Login](https://login.alpha.linode.com/login)
server, you will need to create a new app. On the right-hand side of the screen
is a box. Click Manage API clients. Then fill out the application name
(Linode Manager) and callback URL (http://localhost:3000/oauth/callback). Then
hit Register. Make sure to save the client id and secret to a file.

Note: if you pick a callback url that is not on localhost:3000, you will need to
update the APP_ROOT variable in src/constants.js to point to the different
server.

Now clone the Manager [repo](https://github.com/linode/manager). Make sure npm is
installed then run the following to pull in all dependencies:

```bash
$ npm install
```

Next, create a file "src/secrets.js". Write the following to that file:

```javascript
export const clientId = '<MY_CLIENT_ID>';
export const clientSecret = '<MY_CLIENT_SECRET>';
```

Where the client id and secret are the same as you saved earlier.

Finally, run the manager:

```bash
$ npm start
```

Now in your browser, navigate to [localhost:3000](http://localhost:3000). It
will take a few seconds to build all the files on the first load.
Now that you are in the Manager, you can create a Linode or
look at existing Linodes. And even though this is an Alpha environment, these
are fully working Linodes! You can SSH into them and run servers on them just
like you can with your existing Linodes. However, they are destroyed at least
once a week and may be destroyed freely at any other time without warning.

If the directions here are no longer valid at any time, please submit an
[issue](https://github.com/linode/manager/issues) or a PR.