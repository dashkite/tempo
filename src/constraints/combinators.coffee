import {resolve, extname} from "path"
import {curry, flow} from "panda-garden"
import {equal, first, last, isObject, property} from "panda-parchment"
import {stack} from "@dashkite/katana"
import YAML from "js-yaml"
import log from "../log"

constraint = (f) -> flow [ (stack f), first, property "updates" ]

scoped = (_constraint, pkg, options) ->
  log.info pkg, "check module scope"
  if pkg.scope?
    {data} = await pkg.read "package.json"
    if ! data.name.match ///^@#{pkg.scope}\////
      data.name = "@#{pkg.scope}/#{data.name}"
      # TODO another problem is that we can overwrite updates
      # TODO and toString isn't even defined here
      # TODO what's the relationship between constraint updates
      #      and the package cache?
      _constraint.updates["package.json"] = {content: (toString data), data}
  else
    log.warn pkg, "missing module scope"

file = curry (path, _constraint, pkg, options) ->

  log.info pkg, "check [#{path}]"

  try
    expected = await _constraint.read path
  catch error
    log.warn pkg, "unable to check [#{path}]"
    log.debug pkg, error
    return

  try
    {content} = await pkg.read path
  catch error
    log.debug pkg, error
    content = ""

  if expected != content
    # TODO do we update the pkg cache, as we do with properties?
    _constraint.updates[path] = expected

_match = (object, data) ->
  for key, value of object
    if isObject value
      _match value, data[key]
    else
      if ! equal value, data[key]
        return false
  true

_update = (object, data) ->
  for key, value of object
    if isObject value
      _update value, data[key]
    else
      if ! equal value, data[key]
        data[key] = value
  data

join = (d, ax) -> ax.join d
_format = (object) ->
  join ", ", do ->
    for key, value of object
      if isObject value
        "#{key}.#{_format value}"
      else
        key

properties = curry (path, object, _constraint, pkg) ->

  {content, data} = await pkg.read path

  try
    log.info pkg, "check [%s] in [%s]", (_format object), path
    _update object, data if ! _match object, data
    # TODO this feels like it violates the pkg encapsulation
    #      but it also doesn't make sense to call write here ...
    #      so maybe it's a proposed update?
    pkg.cache[path] = {content: (toString data), data}
    _constraint.updates[path] = content
  catch error
    log.warn pkg, error.message
    log.debug pkg, error

export {constraint, scoped, file, properties}
