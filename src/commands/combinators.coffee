import {shell as _shell, pipe} from "./helpers"
import {curry, tee, rtee, flow} from "panda-garden"
import {chdir as _chdir, write as _write} from "panda-quill"
import _constraints from "../constraints"

# TODO quill/chdir should support async fn
chdir = curry (f, pkg, context) ->
  cwd = process.cwd()
  process.chdir pkg.path
  await f pkg, context
  process.chdir cwd

shell = curry (command, pkg) ->
  pkg.actions.push command

# TODO perhaps we should just compose the constraints into a single flow
constraints = (pkg, context) ->
  for name in pkg.constraints
    await _constraints[name] name, pkg, context

run = (pkg, context) ->
  for action in pkg.actions
    context.logger.info "run [#{action}]"
    unless context.options.rehearse
      try
        pipe (_shell action), context.logger
      catch error
        context.logger.error error

write = (pkg, context) ->
  for path, content of pkg.updates
    context.logger.info "update [#{path}]"
    unless context.options.rehearse
      try
        await _write (resolve pkg.path, path), content
      catch error
        context.logger.error error

announce = (_, context) ->
  context.logger.info "command: %s", context.command
  context.logger.info "options: %s", context.options


export {chdir, shell, constraints, run, write, announce}
