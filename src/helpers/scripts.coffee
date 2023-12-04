import Zephyr from "@dashkite/zephyr"
import { command as exec } from "execa"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import log from "@dashkite/kaiko"

Scripts =

  load: -> Zephyr.read ".tempo/scripts.yaml"

  find: ( name ) ->
    scripts = await do Scripts.load
    scripts[ name ]

Script = 

  expand: ( text, args ) ->
    text
      .replaceAll /\$(\d)/g, ( _, i ) ->
        if args[i]?
          args[i]
        else
          throw new Error "missing positional argument $#{i}"
      .replaceAll /\$@/g, -> args.join " "

  run: ( command, options ) ->
    log.debug run: { command, options }
    result = await exec command, 
      { stdout: "pipe", stderr: "pipe", shell: true, options... }
    log.debug { command, result }
    if result.exitCode != 0
      log.debug { command, result }
      throw new Error result.shortMessage

export { Scripts, Script }

