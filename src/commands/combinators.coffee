import {spawn} from "child_process"
import Path from "path"
import sortPackageJSON from "sort-package-json"
import {identity, unary, binary, curry, tee, rtee, flow,
  flip, spread, pipe, apply as call} from "panda-garden"
import {promise, w, merge} from "panda-parchment"
import {write as _write} from "panda-quill"
import {stack, test, push, pop, peek, apply} from "@dashkite/katana"
import Constraint from "../constraint"
import exec from "../exec"
import log from "../log"

# TODO the version in garden should probably look like this
_apply = (f, args) -> f args...

parseJSON = (json) -> JSON.parse json
formatJSON = (data) -> JSON.stringify data, null, 2
normalizePackageJSON = pipe parseJSON, sortPackageJSON, formatJSON

constraints = (pkg, options) ->
  for name in pkg.constraints
    await Constraint
      .create name
      .run pkg, options

# TODO arguably, a full write belongs in Package?
#      Package.write is a proposed write
#      we could have a Package.commit
#      but presently all logging is done here
#      so that would shift responsibility for that
#      to Package
write = (pkg, options) ->
  unless options.rehearse
    for path, content of pkg.updates
      try
        log.info pkg, "update [#{path}]"
        content = normalizePackageJSON content if path == "package.json"
        await _write (pkg.resolve path), content
      catch error
        pkg.errors.push error
    pkg.updates = {}

# TODO this maybe also belongs in Package?
#      see above re write combinator
report = (pkg) ->
  for path, content of pkg.updates
    log.warn pkg, "[#{path}] needs updating"

json = (text) -> try JSON.parse text

zero = apply ({status}) -> status == 0

nonzero = apply ({status}) -> status != 0

commit = (message) ->
  tee flow [
    push exec "git diff-index --quiet HEAD --"
    test nonzero, flow [
      pop ->
      peek exec "git add -A ."
      peek exec "git commit -m '#{message}'"
    ]
  ]

export {constraints, json, write, report, zero, nonzero, commit}
