import {spawn} from "child_process"
import Path from "path"
import {identity, unary, binary, curry, tee, rtee, flow} from "panda-garden"
import {promise, w, merge} from "panda-parchment"
import {write as _write} from "panda-quill"
import {stack, test, push, pop, peek, restore} from "@dashkite/katana"
import Constraint from "../constraint"
import log from "../log"

# TODO the version in garden should probably look like this
apply = (f, args) -> f args...

utf8 = (data) -> data.toString "utf8"
_shell = (pkg, action) ->
  promise (resolve, reject) ->

    [program, args...] = w action
    path = Path.resolve process.cwd(), pkg.path
    child = spawn program, args, cwd: path, shell: true

    stdout = stderr = ""
    child.stdout.on "data", (data) ->
      text = utf8 data
      log.debug pkg, "[%s] [stdout] %s", action, text
      stdout += text
    child.stderr.on "data", (data) ->
      text = utf8 data
      log.debug pkg, "[%s] [stderr] %s", action, text
      stderr += text
    child.on "error", (error) -> reject error
    child.on "close", (status) -> resolve {action, status, stdout, stderr}

shell = curry (action, pkg, options) ->
  log.info pkg, "run [#{action}]"
  unless options.rehearse
    result = await _shell pkg, action
    if result.status != 0
      log.debug pkg, "[#{action}] exited with a non-zero status"
    result

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
  restore flow [
    push shell "git diff-index --quiet HEAD --"
    test nonzero, flow [
      pop ->
      peek shell "git add -A ."
      peek shell "git commit -m '#{message}'"
    ]
  ]

export {shell, constraints, json, write, report, commit}
