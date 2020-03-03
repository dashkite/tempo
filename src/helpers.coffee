import {tee} from "panda-garden"

squeeze = (f) -> (args...) -> f args

map = tee (f, [iterable, rest...]) ->
  for item from iterable
    await f [ item, rest... ]

Context = create: ({command, options, logger}) -> {command, options, logger}

Package = create: ({path, git, constraints}) ->
  Object.assign {path, git, constraints},
    actions: []
    updates: {}
    cache:
      content: {}
      data: {}

export {squeeze, map, Package, Context}
