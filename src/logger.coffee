import chalk from "chalk"

colors =
  info: chalk.green
  warn: chalk.yellow
  error: chalk.red
  debug: chalk.blue

format = ( level, items ) ->
  items
    .map ( item ) -> colors[ level ] "[ #{ item } ]"
    .join ""

class Logger

  @make: ( scopes ) -> 
    Object.assign ( new Logger ), { scopes }

  scope: ( name ) ->
    Logger.make [ @scopes..., name ]

  label: ( level ) -> format level, @scopes

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