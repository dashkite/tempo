import {spawn} from "child_process"
import Path from "path"
import {identity, unary, curry, tee, rtee, flow} from "panda-garden"
import {promise, w} from "panda-parchment"
import {write as _write} from "panda-quill"
import _constraints from "../constraints"
import log from "../log"

utf8 = (data) -> data.toString "utf8"
_shell = (pkg, action) ->
  promise (resolve, reject) ->

    [program, args...] = w action
    path = Path.resolve process.cwd(), pkg.path
    child = spawn program, args, cwd: path

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
  (pkg) -> pkg.actions.push [ action, handler ]

# TODO perhaps we should just compose the constraints into a single flow
constraints = (pkg, options) ->
  for name in pkg.constraints
    await _constraints[name] name, pkg

run = (pkg, options) ->
  for [ action, handler ] in pkg.actions
    log.info pkg, "run [#{action}]"
    unless options.rehearse
      try
        pkg.results[action] = result = await _shell pkg, action
        if result.status != 0
          pkg.result = false
          log.warn pkg, "[#{action}] exited with a non-zero status"
        handler result, pkg
      catch error
        pkg.result = false
        log.debug pkg, error
        log.error pkg, error.message

write = (pkg, options) ->
  for path, content of pkg.updates
    log.info pkg, "update [#{path}]"
    unless options.rehearse
      try
        await _write (Path.resolve pkg.path, path), content
      catch error
        log.error pkg, error

json = (text) -> try JSON.parse text

results = curry (key, result, pkg) -> pkg.results[key] = result

report = (pkg) ->
  {errors} = pkg
  if !(pkg.result ?= (errors.length == 0))
    for error in errors
      log.warn pkg, "- #{error}"
    log.warn pkg, "see tempo.log for details"

export {shell, constraints, run, write, json, results, report}
