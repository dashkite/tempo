import FS from "node:fs/promises"
import Path from "node:path"
import * as TK from "terminal-kit"
import chalk from "chalk"

colors =
  info: "green"
  warn: "yellow"
  error: "red"
  fatal: "brightRed"
  debug: "blue"

frame = ( text ) -> 
  if text? then "[ #{ text } ]" else ""

space = ( text ) -> " #{ text }"

print = ({ level, data }) ->
  { repo, message } = data
  if message?
    text = chalk.magenta frame "tempo"
    if repo? then text += space chalk.magenta frame repo
    text += space chalk[ colors[ level ]] message
    console[ level ] text

Logger = 

  path: Path.join ".tempo", "logs"

  initialize: -> FS.mkdir Logger.path, recursive: true

  makeFile: ->
    Path.join Logger.path, "#{ ( new Date ).toISOString() }.json"

  printer: ({ quiet }) ->
    if quiet
      ( event ) -> 
        if event.data.console
          print event
    else print

export default Logger
export { Logger }
