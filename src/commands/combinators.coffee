import {shell as _shell, pipe} from "./helpers"
import {curry, tee, rtee, flow} from "panda-garden"
import {write as _write} from "panda-quill"

shell = curry rtee (command, context) ->
  context.actions.push command

constraints = tee (context) ->
  for name in context.constraints
    constraints[name] context

run = tee (context) ->
  for action in context.actions
    context.logger.info action
    unless context.options.rehearse
      try
        pipe (_shell command), context.logger
      catch error
        context.logger.error error

write = tee (context) ->
  for path, content of context.package.updates
    context.logger.info "update [#{path}]"
    unless context.options.rehearse
      try
        await _write (resolve context.package.path, path), content
      catch error
        context.logger.error error

announce = tee (context) ->
  context.logger.info context.command.name
  context.logger.info context.command.options
