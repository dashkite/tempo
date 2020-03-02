import {tee} from "panda-garden"

squeeze = (f) -> (args...) -> f args

map = tee (f, [iterable, rest...]) ->
  for item from iterable
    await f [ item, rest... ]

export {squeeze, map}
