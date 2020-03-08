import {spawn} from "child_process"
import Path from "path"
import {identity, unary, binary, curry, tee, rtee, flow} from "panda-garden"
import {promise, w, merge} from "panda-parchment"
import {write as _write} from "panda-quill"
import {stack, test, push, pop, peek, restore} from "@dashkite/katana"
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

shell = curry (action, pkg, options) ->
  log.info pkg, "run [#{action}]"
  unless options.rehearse
    result = await _shell pkg, action
    if result.status != 0
      log.debug pkg, "[#{action}] exited with a non-zero status"
    result

constraints = (pkg, options) ->
  updates = {}
  for name in pkg.constraints
    # TODO this is returning a stack instead of the updates
    #      the return value isn't even being returned:
    #      we just get the original arguments back as a stack
    #      worked before b/c we'd just updating pkg
    merge updates, await _constraints[name] name, pkg, options
  updates

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
commit = (message) ->
  restore flow [
    push shell "git diff-index --quiet HEAD --"
    test nonzero, flow [
      pop ->
      peek shell "git add -A ."
      peek shell "git commit -m '#{message}'"
    ]
  ]

export {shell, constraints, json, write, notify, commit}
