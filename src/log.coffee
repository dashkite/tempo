import {createWriteStream} from "fs"
import {resolve} from "path"
import util from "util"
import chalk from "chalk"
import {wrap, curry, flow, rtee} from "panda-garden"
import Method from "panda-generics"
import {isType} from "panda-parchment"
import {write} from "panda-quill"
import {stack, push, peek, poke, log as $log} from "@dashkite/katana"
import Package from "./package"


apply = curry (f, args) -> f args...

# TODO we need to figure how to do this via katana API
smpoke = curry (f, stack) -> [ (f stack) ]

format = Method.create
  name: "format"
  default: util.format

logfile = createWriteStream resolve "./tempo.log"
process.on "exit", -> logfile.end()

append = curry (stream, content) -> stream.write content + "\n"

log =

  error: stack flow [
    push wrap "error"
    smpoke apply format
    peek append logfile
    poke chalk.red
    peek append process.stderr
  ]

  warn: stack flow [
    push wrap "warn"
    smpoke apply format
    peek append logfile
    poke chalk.yellow
    peek append process.stderr
  ]

  info: stack flow [
    push wrap "info"
    smpoke apply format
    poke chalk.green
    peek append process.stdout
  ]

  debug: stack flow [
    push wrap "debug"
    smpoke apply format
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
