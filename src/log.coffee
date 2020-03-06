import {createWriteStream} from "fs"
import {resolve} from "path"
import util from "util"
import chalk from "chalk"
import {wrap, curry, flow} from "panda-garden"
import Method from "panda-generics"
import {isType} from "panda-parchment"
import {write} from "panda-quill"
import {stack, push, peek, replace, call, log as _log} from "@dashkite/katana"
import Package from "./package"

format = Method.create
  name: "format"
  default: util.format

logfile = createWriteStream resolve "./tempo.log"
# process.on "exit", -> logfile.end()

append = curry (stream, content) -> stream.write content + "\n"

log =

  error: stack flow [
    push wrap "error"
    call format
    peek append logfile
    replace chalk.red
    peek append process.stderr
  ]

  warn: stack flow [
    push wrap "warn"
    call format
    peek append logfile
    replace chalk.yellow
    peek append process.stderr
  ]

  info: stack flow [
    push wrap "info"
    call format
    replace chalk.green
    peek append process.stdout
  ]

  debug: stack flow [
    push wrap "debug"
    call format
    peek append logfile
  ]

isLevel = (s) -> s in Object.keys log

isRest = (args...) -> true

isPackage = isType Package

format._.define isLevel, isRest, (level, args...) ->
  "tempo [#{level}] #{format args...}"

format._.define isLevel, isPackage, isRest, (level, pkg, args...) ->
  "tempo [#{level}] [#{pkg.path}] #{format args...}"

export default log
