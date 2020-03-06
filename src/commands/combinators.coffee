import {spawn} from "child_process"
import Path from "path"
import {identity, curry, tee, rtee, flow} from "panda-garden"
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

    output = ""
    child.stdout.on "data", (data) ->
      text = utf8 data
      log.debug pkg, "[%s] %s", action, text
      output += text
    child.stderr.on "data", (data) ->
      log.debug pkg, utf8 data
    child.on "error", (error) -> reject error

    child.on "close", (status) ->
      if status == 0
        resolve output
      else
        reject new Error "[#{action}] exited with non-zero status"

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
        handler (await _shell pkg, action), pkg
      catch error
        pkg.result = false
        pkg.errors.push error.message
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

export {shell, constraints, run, write}
