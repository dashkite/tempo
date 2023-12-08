import Path from "node:path"
import Zephyr from "@dashkite/zephyr"
import { command as exec } from "execa"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import log from "@dashkite/kaiko"

truncate = ( text ) ->
  if text.length > 10
    text[ ...10 ] + "..."
  else text

Scripts =

  path: Path.join ".tempo", "scripts.yaml"

  initialize: ->
    Zephyr.update Scripts.path, ( scripts ) -> scripts ?= {}

  load: -> Zephyr.read Scripts.path

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
    try
      result = await exec command, 
        { stdout: "pipe", stderr: "pipe", shell: true, options... }
      log.debug { command, result }
    catch error
      log.error { command, error }
      console.log error
      throw new Error "command failed"

export { Scripts, Script }

