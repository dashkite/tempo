import {shell as _shell, pipe} from "./helpers"
import {curry, tee, rtee, flow} from "panda-garden"
import {write as _write} from "panda-quill"

shell = curry rtee (command, context) ->
  context.actions.push command

constraints = tee (pkg, context) ->
  for name in pkg.constraints
    constraints[name] context

update = tee (pkg, context) ->
  for action in pkg.actions
    context.logger.info action
    unless context.options.rehearse
      try
        pipe (_shell action), context.logger
      catch error
        context.logger.error error

write = tee (pkg, context) ->
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


export {shell, constraints, update, write, announce}
