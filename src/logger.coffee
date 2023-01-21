import chalk from "chalk"

colors =
  info: chalk.green
  warn: chalk.yellow
  error: chalk.red
  debug: chalk.blue

class Logger

  @make: ( scopes ) -> 
    Object.assign ( new Logger ), { scopes }

  scope: ( name ) ->
    Logger.make [ @scopes..., name ]

  label: ( level ) ->
    @scopes
      .map ( item ) -> colors[ level ] "[ #{ item } ]"
      .join ""

  log: ( level, args... ) ->
    console[ level ] ( new Date ),
      ( @label level ),
      args...
  
  error: ( args... ) -> @log "error", args...

  warn: ( args... ) -> @log "warn", args...

  info: ( args... ) -> @log "info", args...

  debug: ( args... ) -> @log "debug", args...

log = Logger.make [ "tempo" ]

export { log }