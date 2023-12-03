import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import Progress from "./helpers/progress"

Command =

  process: do ({ process } = {}) ->

    process = generic
      name: "Command.process"
      default: Fn.identity

    generic process, 
      Type.isReactor,
      ( options, { length, reactor }) ->

        # set up progress bar
        if options.progress
          progress = Progress.make count: length
          progress.set 0
        else
          progress = set: ->

        for await result from reactor
          do progress.increment

  wrap: ( handler ) ->
    ( args..., options ) ->

      # configure logging
      if options.verbose
        log.level "debug"
      else
        log.level "info"

      Command.process options, await handler.apply null, args

      if options.logfile?
        log.write FS.createWriteStream options.logfile    
