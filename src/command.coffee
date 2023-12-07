import FS from "node:fs"
import dayjs from "dayjs"
import * as Fn from "@dashkite/joy/function"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import log from "@dashkite/kaiko"
import Progress from "./helpers/progress"
import printer from "./helpers/logging"
import benchmark from "./helpers/benchmark"

Command =

  wrap: ( handler ) ->
    # ignore the commander object itself
    ( args..., options, _ ) ->

      # configure logging
      if options.verbose
        log.level = "debug"
      else
        log.level = "info"

      log.observe printer quiet: options.progress

      Progress.enabled = options.progress

      log.info 
        console: true
        message: "run at #{( dayjs().format "ddd MMM DD h:mm:ss A" )}"

      duration = await benchmark "tempo", ->
        await handler.apply null, [ args..., options ]
      
      log.info 
        console: true
        message: "finished in #{ duration}s"

      if options.logfile?
        log.write FS.createWriteStream options.logfile

export default Command