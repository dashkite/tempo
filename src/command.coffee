import FS from "node:fs"
import dayjs from "dayjs"
import * as Fn from "@dashkite/joy/function"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import log from "@dashkite/kaiko"
import Progress from "./helpers/progress"
import printer from "./helpers/logging"
import benchmark from "./helpers/benchmark"

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
      Type.isObject,
      ( has [ "length", "reactor" ] ),
      ( options, { length, reactor }) ->

        # set up progress bar
        if options.progress
          progress = Progress.make count: length
          do progress.start

        succeeded = 0
        for await success from reactor
          if success
            succeeded++
            if options.progress
              do progress.increment
            

        if options.progress
          do progress.stop

        log.info 
          console: true
          message: "succeeded: #{ succeeded },
            failed: #{ length - succeeded }"

    process

  wrap: ( handler ) ->
    # ignore the commander object itself
    ( args..., options, _ ) ->

      # configure logging
      if options.verbose
        log.level = "debug"
      else
        log.level = "info"

      log.observe printer quiet: options.progress

      log.info 
        console: true
        message: "run at #{( dayjs().format "ddd MMM DD h:mm:ss A" )}"

      duration = await benchmark "tempo", ->
        await Command.process options, 
          await handler.apply null, [ args..., options ]
      
      log.info 
        console: true
        message: "finished in #{ duration}s"

      if options.logfile?
        log.write FS.createWriteStream options.logfile

export default Command