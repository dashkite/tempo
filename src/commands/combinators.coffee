import {spawn} from "child_process"
import Path from "path"
import {identity, unary, binary, curry, tee, rtee, flow} from "panda-garden"
import {promise, w, merge} from "panda-parchment"
import {write as _write} from "panda-quill"
import {stack, test, push, pop, peek} from "@dashkite/katana"
import Constraint from "../constraint"
import exec from "../exec"
import log from "../log"

# TODO the version in garden should probably look like this
apply = (f, args) -> f args...

constraints = (pkg, options) ->
  apply merge, await do ->
    for name in pkg.constraints
      await Constraint
        .create name
        .run pkg, options

write = (updates, pkg, options) ->
  for path, content of updates
    try
      unless options.rehearse
        log.info pkg, "update [#{path}]"
        await _write (pkg.resolve path), content
    catch error
      pkg.errors.push error

report = (updates, pkg) ->
  for path, content of updates
    log.warn pkg, "[#{path}] needs updating"

json = (text) -> try JSON.parse text

nonzero = ({status}) -> status != 0
commit = (message) ->
  flow [
    push exec "git diff-index --quiet HEAD --"
    test nonzero, flow [
      pop ->
      peek exec "git add -A ."
      peek exec "git commit -m '#{message}'"
    ]
  ]

export {constraints, json, write, report, commit}
