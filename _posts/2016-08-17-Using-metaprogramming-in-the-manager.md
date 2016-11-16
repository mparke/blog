---
# vim: set tw=80
title: Connecting our API to Redux with higher-order functions
layout: post
author: Drew DeVault
avatar: https://www.linode.com/media/images/employees/ddevault.png
tags:
- Manager
---

In our work on the
[new Linode Manager](https://engineering.linode.com/2016/05/16/Announcing-the-new-open-source-manager.html),
we've put some effort into finding reusable ways to manage information from our
API with the Manager's Redux store. We ended up building a module that uses
higher order functions to generate Redux reducers and action creators for this
purpose.

Our new API uses a [consistent, RESTful
design](https://developers.linode.com/reference/), and we wanted to have a
consistent interface for talking to it. The API has support for *lists* of
*resources*, and we built a system wherein we could write up a configuration
object describing a set of endpoints and have the API module generate Redux
reducers and action creators for those endpoints. For a simple example, here's
our distributions reducer, which connects to [this
API](https://developers.linode.com/reference/#ep-distributions):

```javascript
import { distroConfig } from '~/actions/api/distros';
import makeApiList from '~/api-store';

export default makeApiList(distroConfig);
```

Pretty straightforward! Here's the code for the action creator module:

```javascript
import { makeFetchPage, makeFetchAll } from '~/api-store';

export const UPDATE_DISTROS = '@@distributions/UPDATE_DISTROS';

export const distroConfig = {
  singular: 'distribution',
  plural: 'distributions',
  actions: { updateItems: UPDATE_DISTROS },
};

export const fetchDistros = makeFetchPage(distroConfig);
export const fetchAllDistros = makeFetchAll(distroConfig, fetchDistros);
```

Here we define the `UPDATE_DISTROS` Redux action, which will take a list of
distributions returned by the API and update them in the Redux store. The
`distroConfig` object contains a configuration with the plural and singular
forms of the resource (as the API knows them) as well as a list of actions the
generated reducer should support. The action creators `fetchDistros` and
`fetchAllDistros` are created and exported from here. In the reducer module, we
import the same `distroConfig` and pass it into the `makeApiList` function,
which creates a reducer for this config. Thus, fetching all distros from the API
and putting them into the Redux store is as simple as this:

```javascript
import { fetchAllDistros } from '~/actions/api/distros';
dispatch(fetchAllDistros());
```

## Generating action creators

Let's dig into how this stuff works. We'll start with the simple: the
`makeFetchPage` meta action creator. Here's the code for it, with some features
removed for simplicity's sake:

```javascript
export function makeFetchPage(config) {
  function fetchPage(page = 0) {
    return async (dispatch, getState) => {
      const { token } = getState().authentication;
      const path = getPath(config);
      const response = await fetch(token, `${path}?page=${page + 1}`);
      const json = await response.json();
      dispatch({
        type: config.actions.updateItems,
        response: json
      });
      return json;
    };
  }
  return fetchPage;
}
```

The [full
version](https://github.com/linode/manager/blob/9757e6455556d12bba0864a3050c4293b5ec9bd0/src/api-store.js#L211-L255)
includes code for filtering, caching, and subresources, which is omitted
here. The function we see here is a [higher order
function](https://en.wikipedia.org/wiki/Higher-order_function): a function that
operates on functions. The returned function is a Redux [action
creator](http://redux.js.org/docs/basics/Actions.html#action-creators) that
returns a [thunk](https://github.com/gaearon/redux-thunk). When dispatched, this
async function grabs your API token from the Redux store and gets the path in
the API this resource lives at (for example `/linodes/:id`). We fetch this from
the API and then dispatch an action whose type comes from the config and whose
payload is the API response.

The `makeFetchAll` implementation is quite simple with this in place:

```javascript
export function makeFetchAll(config, fetchPage) {
  return () => async (dispatch, getState) => {
    const { state } = getState().api[config.plural];
    if (state.totalPages === -1) {
      await dispatch(fetchPage(0, ...ids));
    }

    for (let i = 1; i < state.totalPages; i++) {
      if (state.pagesFetched.indexOf(i + 1) === -1) {
        await dispatch(fetchPage(i, ...ids));
      }
    }
  };
}
```

This is again a bit simplified from the [full
version](https://github.com/linode/manager/blob/9757e6455556d12bba0864a3050c4293b5ec9bd0/src/api-store.js#L257-L282),
but the basic idea is here. I love ES7's async/await syntax!

## Generating reducers

In our distros example, there was also a one-liner that took a config and
generated a [Redux reducer](http://redux.js.org/docs/basics/Reducers.html):

```javascript
export default makeApiList(distroConfig);
```

This is a [much more complicated
function](https://github.com/linode/manager/blob/9757e6455556d12bba0864a3050c4293b5ec9bd0/src/api-store.js#L24-L157),
so I'll break it down in parts. The core part of most Redux reducers is the
`switch...case` statement:

```javascript
export default function makeApiList(config) {
  const actions = {
    updateItem: -1,
    updateItems: -1,
    deleteItem: -1,
    ...config.actions,
  };

  const mergedConfig = { ...config, actions };
  const defaultState = makeDefaultState(mergedConfig);

  // ...

  function handleAction(_config, state, action) {
    switch (action.type) {
      case _config.actions.updateItems:
        return updateMany(_config, state, action);
      case _config.actions.updateItem:
        return updateItem(_config, state, action);
      case _config.actions.deleteItem:
        return deleteOne(_config, state, action);
      default:
        return state;
    }
  }

  return (state = defaultState, action) =>
    handleAction(mergedConfig, state, action);
}
```

Some of the less relevant features of our system (filtering and caching and
subresources) are again omitted. This switches on the action type, but checks
for actions whose type is one provided in the config object. The Redux state for
an API store looks something like this:

```javascript
{
  distributions: {
    pagesFetched: [ 1 ],
    totalPages: 1,
    totalResults: 20,
    singular: "distribution",
    plural: "distributions",
    distributions: {
      "linode/debian8": { ... },
      "linode/fedora21": { ... },
      "linode/ubuntu15.4": { ... },
      // ...
    },
  },
}
```

The "distributions" object is keyed on the ID of the resource. So, the
implementation for `_config.actions.updateItem` looks like this:

```javascript
  function updateItem(_config, state, action) {
    const item = action[_config.singular];
    return {
      ...state,
      [_config.plural]: {
        ...state[_config.plural],
        [item.id]: {
          ...state[_config.plural][item.id],
          ...item,
        },
      },
    };
  }
```

The implementation for updating a page of items looks like this:

```javascript
function updateMany(_config, state, action) {
  const { response } = action;
  return {
    ...state,
    pagesFetched: [
      ...state.pagesFetched.filter(p => p !== response.page),
      response.page,
    ],
    totalPages: response.total_pages,
    totalResults: response.total_results,
    [_config.plural]: {
      ...state[_config.plural],
      ...response[_config.plural].reduce((s, i) =>
        ({ ...s, [i.id]: transform(
           transformItem(_config.subresources, i)) }), { }),
    },
  };
}
```

## Extra details

I omitted several things from these examples that you could investigate more in
our [GitHub repository](https://github.com/Linode/manager) if it interests you,
such as:

* Server-side filtering
* Caching and cache invalidation
* Subresources (such as /linodes/:id/disks)

Thanks for stopping by! I hope you've learned something neat to apply to your
own React projects. I'll leave you with the simple code for our most complicated
set of API endpoints, the Linodes endpoints:

```javascript
import {
  makeFetchPage,
  makeFetchAll,
  makeFetchItem,
  makeFetchUntil,
  makeDeleteItem,
  makePutItem,
  makeCreateItem,
} from '~/api-store';

export const UPDATE_LINODES = '@@linodes/UPDATE_LINODES';
export const UPDATE_LINODE = '@@linodes/UPDATE_LINODE';
export const DELETE_LINODE = '@@linodes/DELETE_LINODE';

export const UPDATE_LINODE_CONFIG = '@@linodes/UPDATE_LINODE_CONFIG';
export const UPDATE_LINODE_CONFIGS = '@@linodes/UPDATE_LINODE_CONFIGS';
export const DELETE_LINODE_CONFIG = '@@linodes/DELETE_LINODE_CONFIG';

export const UPDATE_LINODE_DISK = '@@linodes/UPDATE_LINODE_DISK';
export const UPDATE_LINODE_DISKS = '@@linodes/UPDATE_LINODE_DISKS';
export const DELETE_LINODE_DISK = '@@linodes/DELETE_LINODE_DISK';

export const UPDATE_BACKUPS = '@@backups/UPDATE_BACKUPS';
export const UPDATE_BACKUP = '@@backups/UPDATE_BACKUP';

export const linodeConfig = {
  plural: 'linodes',
  singular: 'linode',
  actions: {
    updateItem: UPDATE_LINODE,
    updateItems: UPDATE_LINODES,
    deleteItem: DELETE_LINODE,
  },
  subresources: {
    _configs: {
      plural: 'configs',
      singular: 'config',
      actions: {
        updateItem: UPDATE_LINODE_CONFIG,
        updateItems: UPDATE_LINODE_CONFIGS,
        deleteItem: DELETE_LINODE_CONFIG,
      },
    },
    _disks: {
      plural: 'disks',
      singular: 'disk',
      actions: {
        updateItem: UPDATE_LINODE_DISK,
        updateItems: UPDATE_LINODE_DISKS,
        deleteItem: DELETE_LINODE_DISK,
      },
    },
    _backups: {
      plural: 'backups',
      singular: 'backup',
      actions: {
        updateItem: UPDATE_BACKUP,
        updateItems: UPDATE_BACKUPS,
      },
    },
  },
};

export const fetchLinodes = makeFetchPage(linodeConfig);
export const fetchAllLinodes = makeFetchAll(linodeConfig, fetchLinodes);

export const fetchLinode = makeFetchItem(linodeConfig);
export const fetchLinodeUntil = makeFetchUntil(linodeConfig);

export const deleteLinode = makeDeleteItem(linodeConfig);
export const putLinode = makePutItem(linodeConfig);
export const createLinode = makeCreateItem(linodeConfig);

export const fetchLinodeDisk = makeFetchItem(linodeConfig, 'disks');
export const fetchLinodeDisks = makeFetchPage(linodeConfig, '_disks');
export const fetchAllLinodeDisks = makeFetchAll(linodeConfig, fetchLinodeDisks, '_disks');

export const fetchLinodeConfig = makeFetchItem(linodeConfig, 'configs');
export const fetchLinodeConfigs = makeFetchPage(linodeConfig, '_configs');
export const fetchAllLinodeConfigs = makeFetchAll(linodeConfig, fetchLinodeConfigs, '_configs');
```
