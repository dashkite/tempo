import {curry, tee, rtee, flow} from "panda-garden"
import {write as _write} from "panda-quill"
import _constraints from "../constraints"
import log from "../log"

_shell = (pkg, action) ->

  [program, args...] = w action
  path = resolve process.cwd(), pkg.path
  child = spawn program, args, cwd: path

  output = ""
  child.stdout.on "data", (data) ->
    log.info data
    result += data
  child.stderr.on "data", (data) -> log.error pkg, data
  child.on "error", (error) -> reject error

  child.on "close", (status) ->
    if status == 0
      resolve output
    else
      reject new Error "child process exited with non-zero status: #{status}"

shell = (action, handler) ->
  (pkg) -> pkg.actions.push [ action, handler ]

# TODO perhaps we should just compose the constraints into a single flow
constraints = (pkg, options) ->
  for name in pkg.constraints
    await _constraints[name] name, pkg

run = (pkg, options) ->
  for [ action, handler ] in pkg.actions
    log.info "run [#{action}]"
    unless options.rehearse
      try
        result = _shell pkg, action
        handler? result, pkg
      catch error
        log.error pkg, error

write = (pkg, options) ->
  for path, content of pkg.updates
    log.info pkg, "update [#{path}]"
    unless options.rehearse
      try
        await _write (resolve pkg.path, path), content
      catch error
        log.error pkg, error

export {shell, constraints, run, write}
