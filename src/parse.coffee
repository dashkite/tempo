
import {re, string, list as _list, between, all, any, many, optional,
  tag, merge, join, rule, grammar} from "panda-grammar"
import {isArray, isString} from "panda-parchment"

log = (label, p) ->
  rule p, (result) ->
    console.log [label]: result
    result

ws = re /^\s+/
text = string
strip = (p) -> rule p, ({value}) ->
  if isArray value
    item for item in value when !(isString item) || !(/^\s+$/.test item)
  else value

compact = (p) -> rule p, ({value}) ->
  item for item in value when item?

first = (p) -> rule p, ({value}) -> value[0]
second = (p) -> rule p, ({value}) -> value[1]

# TODO why isn't this in parchment?
_flatten = (ax) ->
  bx = []
  for a in ax
    if isArray a then bx.push (_flatten a)... else bx.push a
  bx

flatten = (p) -> rule p, ({value}) -> _flatten value

reverse = (p) -> rule p, ({value}) -> value.reverse()

flag = (p) -> rule p, ({value}) -> [value]: true

# verify command
dependencies = text "dependencies"
build = text "build"
exemplars = text "exemplars"
verify = compact all (text "verify"),
  (optional first strip all ws,
    (tag "scope", (any dependencies, build, exemplars)))

# update command
wildstyle = text "wildstyle"
update = compact all (text "update"),
  (optional first strip all ws, flag wildstyle)

# refresh command
refresh = all text "refresh"

# bump command
major = text "major"
minor = text "minor"
version = compact all (text "version"),
  (optional first strip all ws, (flag any major, minor))

# publish command
publish = all text "publish"

# packages command
list = tag "subcommand", text "list"
add = tag "subcommand", text "add"
remove = tag "subcommand", text "remove"
diff = tag "subcommand", text "diff"
packages = strip all (text "packages"), ws, (any list, add, remove, diff)

# all the subcommands
subcommands = (any verify, update, refresh, version, publish, packages)

# rehearse command
rehearse = rule (second strip all (text "rehearse"), ws, subcommands),
  ({value: [command, options]}) ->
    options ?= {}
    options.rehearse = true
    [command, options]

# grammar
# - path for now is just non-ws
# TODO allow for ws in paths?
path = re /^\S+/
command = rule (all (any subcommands, rehearse),
  optional second all ws, tag "path", path),
  ({value: [[command, options], _options]}) ->
    if _options?.path?
      options ?= {}
      options.path = _options.path
      [command, options]
    else
      [command, options]


parse = grammar command

export default parse
