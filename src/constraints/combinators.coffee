import {binary, ternary, curry, rtee} from "panda-garden"
import {equal, last} from "panda-parchment"

lookup = (keys, object) ->
  current = object
  for key in keys.split "."
    break unless current?
    current = current?[key]
  current

log =
  info: (args...) -> console.log "tempo:", args...
  warn: (args...) -> console.warn "tempo:", args...
  error: (args...) -> console.error "tempo:", args...

constraint = ({name, verify, refresh, success, failure}) ->
  rtee (args...) ->
    context = last args
    context.constraints.push (results = {name})
    try
      if verify args...
        if context.refresh
          refresh args...
        results.success = success args...
      else
        results.failure = failure args...
    catch error
      results.failure = failure args...
      results.error = error

property = curry ternary constraint

  name: "package.json"

  verify: (key, value, context) ->
    equal value, lookup key, context.package

  refresh: (key, value, context) ->

  success: (key, value, context) ->
    if context.refresh
      "updated [#{key}] to [#{value}] in package.json"
    else
      "verified [#{key}] == [#{value}] in package.json"

  failure: (key, value, context) ->
    if context.refresh
      "error updating [#{key}] to [#{value}] in package.json"
    else
      "[#{key}] != [#{value}] in package.json"


export {property}
