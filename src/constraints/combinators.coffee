import {curry, rtee} from "panda-garden"
import {equal} from "panda-parchment"

lookup = (key, object) ->
  current = object
  for keys in key.split "."
    break unless current?
    current = current?[key]
  current

property = (key, value, context) ->
  equal value, lookup key, context.package


export {property}
