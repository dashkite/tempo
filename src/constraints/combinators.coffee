import {resolve, extname} from "path"
import {curry, flow} from "panda-garden"
import {equal, first, last, isObject, property} from "panda-parchment"
import YAML from "js-yaml"
import log from "../log"

scoped = (_constraint, pkg, options) ->
  log.info pkg, "check module scope"
  if pkg.scope?
    {data} = await pkg.read "package.json"
    if ! data.name?.match? ///^@#{pkg.scope}\////
      data.name = "@#{pkg.scope}/#{data.name}"
      pkg.write "package.json", {data}
  else
    log.warn pkg, "scope undefined"

file = curry (path, _constraint, pkg, options) ->

  log.info pkg, "check [#{path}]"

  # TODO this might belong within Constraint
  _path = path.replace /^\./, "dot-"

  try
    expected = await _constraint.read _path
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
    pkg.write path, content: expected

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

properties = curry (path, object, _, pkg) ->

  {content, data} = await pkg.read path

  try
    log.info pkg, "check [%s] in [%s]", (_format object), path
    if ! _match object, data
      _update object, data
      pkg.write path, {data}
  catch error
    log.warn pkg, error.message
    log.debug pkg, error

export {scoped, file, properties}
