
import {re, string, list as _list, between, all, any, many, optional,
  tag, merge, join, rule, grammar} from "panda-grammar"
import {isArray, isString} from "panda-parchment"

ws = re /^\s+/
text = string
strip = (p) -> rule p, ({value}) ->
  if isArray value
    item for item in value when !(isString item) || !(/^\s+/.test item)
  else value

compact = (p) -> rule p, ({value}) ->
  item for item in value when item?

first = (p) -> rule p, ({value}) -> value[0]
second = (p) -> rule p, ({value}) -> value[1]

flag = (p) -> rule p, ({value}) -> [value]: true

# verify command
dependencies = text "dependencies"
build = text "build"
constraints = text "constraints"
verify = compact all (text "verify"),
  (optional first strip all ws,
    (tag "scope", (any dependencies, build, constraints)))


# update command
wild = text "wild"
update = compact all (text "update"),
  (optional first strip all ws, flag wild)

# refresh command
refresh = text "refresh"

# bump command
major = text "major"
minor = text "minor"
bump = compact all (text "bump"),
  (optional first strip all ws, (flag any major, minor))

# publish command
publish = text "publish"

# packages command
list = text "list"
add = text "add"
remove = text "remove"
diff = text "diff"
packages = strip all (text "packages"), ws, (any list, add, remove, diff)

# grammar
command = second strip all (text "tempo"), ws,
  (any verify, update, refresh, bump, publish, packages)

parse = grammar command

export {parse}
