import {spawn} from "child_process"
import Path from "path"
import {identity, unary, curry, tee, rtee, flow} from "panda-garden"
import {promise, w} from "panda-parchment"
import {write as _write} from "panda-quill"
import {stack, test, pop, peek} from "@dashkite/katana"
import _constraints from "../constraints"
import log from "../log"

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

shell = (action, handler = identity) ->
  (pkg, options) ->
    log.info pkg, "run [#{action}]"
    unless options.rehearse
      try
        result = await _shell pkg, action
        if result.status != 0
          pkg.result = false
          log.debug pkg, "[#{action}] exited with a non-zero status"
        handler result, pkg, options
      catch error
        pkg.result = false
        log.debug pkg, error
        log.error pkg, error.message

# TODO perhaps we should just compose the constraints into a single flow
constraints = curry (handler, pkg, options) ->
  updates = {}
  for name in pkg.constraints
    await _constraints[name] updates, pkg, options
  handler updates, pkg, options

write = (updates, pkg, options) ->
  for path, content of updates
    try
      unless options.rehearse
        log.info "update [#{path}]"
        await write (resolve pkg.path, path), content
    catch error
      log.debug error

notify = (updates, pkg) ->
  for path, content of updates
    log.warn pkg, "[#{path}] needs updating"

json = (text) -> try JSON.parse text

nonzero = ({status}) -> status != 0

commit = shell "git diff-index --quiet HEAD --", stack flow [
    test nonzero, flow [
      pop ->
      peek shell "git add -A ."
      peek shell "git commit -m 'tempo refresh'"
    ]
  ]

export {shell, constraints, json, commit, write, notify}
