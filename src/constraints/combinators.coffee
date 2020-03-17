import {resolve, extname} from "path"
import {curry, flow} from "panda-garden"
import {equal, first, last, isObject, property} from "panda-parchment"
import {read} from "panda-quill"
import {stack} from "@dashkite/katana"
import YAML from "js-yaml"
import log from "../log"

constraint = (f) -> flow [ (stack f), first, property "updates" ]

# TODO this message gets logged twice for update/refresh
file = curry (path, constraint, pkg, options) ->
  log.info pkg, "check [#{path}]"
  try
    # TODO path helpers for package/constraint might be nice
    #      ex: read Constraint.resolve constraint, path
    #      or shorthand version: constraint.resolve path
    expected = await read constraint.resolve path
    try
      actual = await read pkg.resolve path
    catch error
      log.debug pkg, "unable to read [#{path}]"
      log.debug pkg, error
      actual = ""
    if expected != actual
      constraint.updates[path] = expected
  catch error
    log.warn pkg, error.message
    log.debug error

serializer = (extension) ->
  switch extension[1..]
    when "json"
      fromString: JSON.parse
      toString: JSON.stringify
    when "yaml"
      fromString: YAML.safeLoad
      toString: YAML.safeDump
    else
      throw new Error "unrecognized extension [#{extension}]"

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

properties = curry (path, object, context, pkg) ->

  {fromString, toString} = serializer extname path

  if (cached = context.cache[path])?
    {content, data} = cache
  else
    content = await read resolve pkg.path, path
    data = fromString content
    context.cache[path] = {content, data}

  try
    log.info pkg, "check [%s] in [%s]", (_format object), path
    if ! _match object, data
      _update object, data
      content = toString data
      context.cache[path] = {context, data}
      context.updates[path] = content
  catch error
    log.warn pkg, error.message
    log.debug pkg, error

export {constraint, file, properties}
