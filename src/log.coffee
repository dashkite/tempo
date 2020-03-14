import {createWriteStream} from "fs"
import {resolve} from "path"
import util from "util"
import chalk from "chalk"
import {wrap, curry, flow} from "panda-garden"
import Method from "panda-generics"
import {isType} from "panda-parchment"
import {write} from "panda-quill"
import {stack, push, peek, poke, log as $log} from "@dashkite/katana"
import Package from "./package"


# TODO we need to figure how to do this via katana API
#      this seems like a pretty normal thing to want to do ...
#      with the old spush API we could just write
#
#          spush apply format
#
#      so maybe we should add those back?
#

apply = curry (f, stack) -> [ (f stack...), stack ]

format = Method.create
  name: "format"
  default: util.format

logfile = createWriteStream resolve "./tempo.log"
process.on "exit", -> logfile.end()

append = curry (stream, content) -> stream.write content + "\n"

log =

  error: stack flow [
    push wrap "error"
    apply format
    peek append logfile
    poke chalk.red
    peek append process.stderr
  ]

  warn: stack flow [
    push wrap "warn"
    apply format
    peek append logfile
    poke chalk.yellow
    peek append process.stderr
  ]

  info: stack flow [
    push wrap "info"
    apply format
    poke chalk.green
    peek append process.stdout
  ]

  debug: stack flow [
    push wrap "debug"
    apply format
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
