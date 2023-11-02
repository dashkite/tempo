# TODO make variable substition more robust
# TODO remove this feature in favor of env vars?
expand = ( text, argv ) ->
  text
    .replaceAll /\$(\d)/g, ( _, i ) ->
      if argv[i]?
        argv[i]
      else
        throw new Error "tempo: missing positional argument $#{i}"
    .replaceAll /\$@/g, -> argv.join " "

import { command as exec } from "execa"

run = ( action, options ) ->
  result = await exec action, 
    { stdout: "pipe", stderr: "pipe", shell: true, options... }
  if result.exitCode != 0
    throw new Error result.stderr

round = do ( formatter = undefined ) -> 
  ( n ) ->
    formatter ?= Intl.NumberFormat "en",
      minimumFractionDigits: 2
      maximumFractionDigits: 2
    formatter.format n

import * as TK from "terminal-kit"

progress = ( { count }, f ) ->
  bar = TK.terminal.progressBar
    title: "Progress"
    percent: true
    eta: true
    barChar: "◼︎"
    barHeadChar: "◼︎"
  counter = 0
  await f increment: -> bar.update ++counter / count
  TK.terminal "\n"


import { performance as Performance } from "node:perf_hooks"

benchmark = ( name, f ) ->
  Performance.mark "#{ name }-start"
  await f()
  Performance.mark "#{ name }-finish"
  { duration } = Performance.measure name, 
    "#{ name }-start", 
    "#{ name }-finish"
  ( round duration / 1000 )


import FS from "node:fs/promises"

isDirectory = ( name ) ->
  try
    ( await FS.stat name ).isDirectory()
  catch
    false

import { log } from "./logger"

ignore = ( list, options ) ->
  for item in list
    if options[ item ]?
      log.warn "ignoring option [ #{ item } ]"
  null

export {
  expand
  run
  round
  progress
  benchmark
  isDirectory
  ignore
}