import { fatal } from "./messages"
import usage from "./usage"


getOptions = ->

  do ( options = {}, argv = process.argv[2..], arg = undefined ) ->
    while argv.length > 0
      switch ( arg = argv.shift() )
        when "-p", "--project"
          options.project = argv.shift()
        when "-a", "--actions"
          options.actions = argv.shift()
        when "-h", "--help"
          usage()
        else
          if arg.startsWith "-"
            fatal "unknown option '#{ arg }'"
          else
            options.path ?= arg

    if ( options.project? || options.actions? ) && options.path?
      fatal "option '--path' cannot be used with
             '--project' or '--actions'"
    else if ( options.project? && options.actions? ) || options.path?
      options
    else if options.project?
      fatal "option '--actions' is required with '--project'"
    else if options.actions?
      fatal "option '--project' is required with '--actions'"
    else
      fatal "invalid options, use '--help' for help"

export default getOptions