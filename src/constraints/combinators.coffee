import {resolve, extname} from "path"
import {binary, ternary, curry, rtee} from "panda-garden"
import {equal, last, isArray, isObject, isString} from "panda-parchment"
import {read} from "panda-quill"
import Method from "panda-generics"
import YAML from "js-yaml"
import log from "../log"


_lookup = Method.create()
Method.define _lookup, isArray, isObject, (keys, object) ->
  current = object
  for key in keys
    break if !current?
    current = current?[key]
  if current then current
  else throw new Error "invalid key [#{keys.join "."}]"

Method.define _lookup, isString, isObject, (reference, object) ->
  _lookup (reference.split "."), object

_update = Method.create()
isAny = (-> true)

Method.define _update, isArray, isAny, isObject,
  ([keys..., key], value, object) -> (_lookup keys, object)[key] = value

Method.define _update, isString, isAny, isObject, (reference, value, object) ->
  _update (reference.split "."), value, object

# TODO this message gets logged twice for update/refresh
file = curry (path, constraint, pkg, options) ->
  log.info pkg, "check [#{path}]"
  try
    # TODO path helpers for package/constraint might be nice
    #      ex: read Constraint.resolve constraint, path
    #      or shorthand version: constraint.resolve path
    expected = await read constraint.resolve path
    actual = await read pkg.resolve path
    if expected != actual
      constraint.updates[path] = expected
  catch error
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

property = curry rtee (path, key, value, context) ->

  {fromString, toString} = serializer extname path

  if (cached = context.package.cached[path])?
    {content, data} = cache
  else
    content = await read resolve context.package.path, path
    data = fromString content
    context.package.cached[path] = {content, data}

  try
    if value != _lookup key, data
      _update key, value, data
      log.info context, "update [#{key}] to [#{value}] in [#{path}]"
      context.package.updates[path] = toString data
  catch error
    log.warn context, error.message

properties = (path, dictionary) ->
  flow ((property key, value) for key, value of dictionary)

export {file, property, properties}
