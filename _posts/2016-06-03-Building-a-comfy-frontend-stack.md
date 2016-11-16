---
# vim: tw=80
title: How we picked a comfortable frontend stack and settled into its ecosystem
author: Drew DeVault
avatar: https://www.linode.com/media/images/employees/ddevault.png
layout: post
tags:
- Manager
---

In the JavaScript world today there are tons of shiny new projects out there and
it's overwhelming to figure out how to build a large product from the ground up.
Before starting on [the new Linode Manager](https://github.com/Linode/manager),
we had a long period of internal prototyping and developer discussions to find
the ideal frontend stack for the project. Three main prototypes emerged, based
on [React.js](http://facebook.github.io/react/),
[Angular](https://angularjs.org/), and [Mithril](http://mithril.js.org/). Each
of these platforms ships a different broader design philosophy.

React.js (note: when I talk about React.js, I'm referring to
React+[Redux](https://github.com/reactjs/redux)) brings a lot of functional
programming concepts to the table. Angular is a declarative MVC framework and
lives alongside things like [Knockout.js](http://knockoutjs.com/) and
Microsoft's
[WPF](https://msdn.microsoft.com/en-us/library/ms754130(v=vs.110).aspx)
platform. Mithril is a sort of balance between both, with an MVC-driven design
with some similarities to React. We also tried several different variations on
JavaScript with each of these prototypes. The Mithril prototype used ES5, the
Angular prototype used [TypeScript](http://www.typescriptlang.org/), and the
React.js prototype used [ES6 and
ES7](https://hacks.mozilla.org/2015/04/es6-in-depth-an-introduction/).

We set a goal for ourselves: build a prototype that can log into your Linode
account via OAuth and list your Linodes, as well as a detail page. The idea is
that we'd demonstrate several important things in the context of each framework:

1. The OAuth flow
1. Talking to the API
1. Routing
1. Rendering to the DOM

For bonus points we could show off anything your framework did that was
particularly cool, like hot module reloading. I made a React prototype, my
colleagues Marques and Abe helped - Marques did the Angular 2 prototype, and Abe
did the Mithril prototype. Eventually we presented our prototypes and
recommendations to the rest of the development team.

## Angular 2 & TypeScript

Marques started the Angular prototype with the official [Angular 2
seed](https://github.com/angular/angular2-seed). Angular presents a significant
evolution on the concepts the web has been developing over the past several
years with tools like Knockout, Backbone, Require.js, and so on. It takes the
best tools of the past 4 years or so of JavaScript and makes them into a modern,
cohesive package. The use of TypeScript here also brings along some of the nice
features of ES6 plus a strong type system for object oriented programming. It's
no surprise TypeScript came out of Microsoft - it's pretty similar to C#. The
Angular + TypeScript stack should feel very comfortable for .NET programmers who
want to easily transition into the web.

For those who want this more traditional object oriented model, Angular seems to
be excellent. It has support for [dependency
injection](https://docs.angularjs.org/guide/di) and adding TypeScript brings a
lot of value. It also provides a comprehensive framework that handles everything
from routing to HTTP requests for you, with detailed documentation. However,
for some of the more volatile features, Marques found the documentation
confusing, incomplete, and inconsistent. This'll probably cease to be an issue
once Angular 2 is released properly.

Angular also offers some innovative ways of managing your data with the
observables mechanic. They basically work like Unix pipes and let you chain
operations together and subscribe to changes anywhere in the pipeline, then
respond to those changes in your application. Angular is also well tested and
the community has many examples, though some may be outdated (which is a problem
for all three of the options we're looking at today).

There are some disadvantages to Angular. Though Google has promised improvements
to this, Angular 2 is pretty slow. There are lots of debugging things going on
and the startup times are rough. The transition from Angular 1 to Angular 2 is
also very jarring and those with preconceptions about how Angular works are
going to have a hard time. Some people also criticize the "do everything"
approach that Angular takes, preferring the Unix philosophy where tools and
libraries with a smaller scope are composed to fill the full picture.

## Mithril & ES5

Mithril is for those who took the lessons of the past few years of JavaScript
and concluded that not much needed to change. Abe quickly realized that Mithril
was not the right call, but he soldiered on to be absolutely sure and see if
there were any lessons to be learned that could be applied to our eventual
choice. Abe had some praise for it, though. One of the big positives to Mithril
is that it's very quick to get up and running. There's no transpiling or
boilerplate to set up, no webpack or gulp, no package.json, or anything like
that. You can just drop it into your page and get started like any old school
JavaScript library. It's also pretty simple for developers who are comfortable
with ES5 libraries and patterns to understand and use.

Abe found that the deeper he got into it, though, the less effective it was. The
documentation is lacking and it handles more complex situations poorly. He also
called some criticism on its separation of concerns, noting that idiomatic
Mithril models are aware of the DOM. ES5 is also a pretty bad language, which
we've all known for a long time. Transpiling is the right call for your sanity.

I also asked Abe about the MVC pattern in general, and he still feels like it's
the right call in some situations. Abe worries that once your application gets
big enough and cross dependencies start to pile up, MVC falls apart. [Facebook
feels the same way](http://facebook.github.io/flux/) (though I think the
prevailing thought is that Flux isn't quite right, either).

## React.js & ES6

React.js is Facebook's offering for the new age of JavaScript, and Redux is a
design philosophy that most people are using with React these days. It takes
functional programming paradigms and introduces them to the web. The idea is
this: you describe the state of your application in a single JavaScript object.
If you have a checkbox that toggles the visibility of foobar, it's in your state
as `foobar: true`.  You then write your UI as a [pure
function](https://en.wikipedia.org/wiki/Pure_function) of your state. Given this
state, you return either `<input type="checkbox" />` or `<input type="checkbox"
checked="checked" />`. When the checkbox is ticked, you create a new state that
has that boolean flipped and rerender your UI. Your entire application is
described in this way, and it ends up being a single JavaScript function that
you can pass a state object into it and it returns what the DOM should be when
the application is in that state.

This sounds pretty radical to someone who is used to imperative programming
instead of functional programming, like I was pre-React. An idiomatic
React+Redux code base is *not* object oriented. Your code and your data are kept
separate and [you never mutate
anything](https://en.wikipedia.org/wiki/Immutability). This is one of the big
drawbacks to React: it was much harder for me and my coworkers to grok it. By
accepting this radical change to your development philosophy, you get some
seriously awesome advantages. Your code is easier to reason about, more
testable, and more consistent. It also enables some really cool things like
[time travel](https://www.youtube.com/watch?v=xsSnOQynTHs) and hot reloading
*all* of your code on the fly!

ES6 is also great. It fixes almost every complaint I have about JavaScript.
Writing ES6 code is much easier and more fun than writing ES5 code. The same
goes for TypeScript, but since we aren't object oriented in the React world we
don't stand to gain much from TS. Some things from the future (ES7) are also
pretty great - in particular
[async/await](https://jakearchibald.com/2014/es7-async-functions/) are fantastic
and our codebase has got a lot of mileage out of [object
spreading](https://github.com/sebmarkbage/ecmascript-rest-spread).

The downsides to React do exist, though. One of them is the documentation - it
can be difficult to find the answers you're looking for. React also showed up
during the ES5 era and has struggled to move smoothly into the ES6 era. I get
frustrated when I have to bind all of my functions in the constructor of my ES6
classes. Above all, though, the biggest pain point with React is setting up the
damn codebase. Getting all of the pieces together and working the right way took
me ages and was extremely painful. I'm also [not a big
fan](https://medium.com/@azerbike/i-ve-just-liberated-my-modules-9045c06be67c)
of how big our dependency tree is.

## React wins!

We picked React.js and later started implementing our new manager on top of it.
The new manager is open source, you can check out our progress [on
GitHub](https://github.com/Linode/manager). I also personally suggest that if
you choose to make a React app, you fork it and gut it and base yours on ours to
avoid the *massive* headache it'll be putting all of the pieces together.
Development on the new manager is going very well. We just finished adding test
coverage for all of the things we intend to test right now, and we're diving
into fleshing out our application. React is a radical change for the JS
community, but thanks to it I finally feel good about writing JavaScript. On the
shoulders of React we are finally able to build a maintainable, scalable, and
elegant large-scale codebase in JavaScript. It feels good, doesn't it?

## Problems we ran into

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Clarification on my praise of React/Redux/etc - it&#39;s great once you can get it set up and only if you never have to touch your build again</p>&mdash; Drew DeVault (@SirCmpwn) <a href="https://twitter.com/SirCmpwn/status/732598136431087617">May 17, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

I almost wrote the prototype from scratch. I originally used gearon's [Redux hot
loader starter kit](https://github.com/gaearon/react-hot-boilerplate), which
gives you the bare minimum necessary to get React and Redux hot loading in an
application. We added the rest over time, and it has been a massive pain in the
ass. We started with this:

* React.js
* Redux reducers and actions
* Hot reloading

And we had to deal with all of this:

* Routing
* Setting up and maintaining [Webpack](http://mochajs.org/)
* [Babel](http://babeljs.io/) 5->6 transition
* SCSS loading (and hot reloading)
* Linting
* Getting tests to work
    * Setting up [Mocha](http://mochajs.org/)
    * Getting [Karma](https://karma-runner.github.io/0.13/index.html) working
    * Getting Webpack and Karma and Mocha to cooperate
    * Getting [enzyme](https://github.com/airbnb/enzyme) working
    * Getting [Sinon](https://webpack.github.io/) working
    * Code coverage reporting

All of these things do not always play nice together. There are many versions of
each of them and they're all subtly broken and incompatible with each other. It
literally took me 2 full days of work to switch from running tests on Mocha to
running tests with Karma. If you value your sanity I highly suggest you just
take our open source repository and repurpose it for your needs.

## Conclusion

Was React.js worth it? Well, I think so. I've never seen such a strong
JavaScript codebase as the one we're working on now. Once all the meta BS is out
of the way, you can develop very quickly and with high confidence in the
reliability and maintainability of your code. I'm glad we explored the other
options as well - I imagine that a tool like Angular may very well be useful to
us in the future for more projects, and it was great to find and understand the
sore points of each framework by building a non-trivial prototype with them.
