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

printer = ({ quiet }) ->
  if quiet
    ( event ) -> ( print event ) if event.data.console
  else print

export default printer
export { printer }