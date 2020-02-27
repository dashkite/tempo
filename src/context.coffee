import {tee} from "panda-garden"

Context =

  create: ({command, options, logger}) ->
    command: command
    options: options
    logger: logger
    constraint:
      cached: {}
    messages:
      info: []
      warn: []
      fatal: []

  # TODO maybe a better way to do this?
  package: tee (context, description) ->
    context.package = description

export default Context
