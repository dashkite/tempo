import * as Fn from "@dashkite/joy/function"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import Progress from "./helpers/progress"
import log from "@dashkite/kaiko"
import "./logging"

# TODO find a home for this
has = ( keys ) -> 
  if !( Type.isArray keys )
    keys = [ keys ]
  ( value ) -> keys.every ( key ) -> value[ key ]?

Command =

  process: do ({ process } = {}) ->

    process = generic
      name: "Command.process"
      default: Fn.identity

    generic process, 
      ( has "reactor" ),
      ( options, { length, reactor }) ->

        # set up progress bar
        if options.progress
          progress = Progress.make count: length

        for await result from reactor
          if options.progress
            do progress.increment

        return # don't return the comprehension
    
    process

  wrap: ( handler ) ->
    # ignore the commander object itself
    ( args..., options, _ ) ->

      # configure logging
      if options.verbose
        log.level = "debug"
      else
        log.level = "info"

      Command.process options, await handler.apply null, args

      if options.logfile?
        log.write FS.createWriteStream options.logfile    

export default Command