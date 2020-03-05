import parse from "./parse"
import run from "./run"
import log from "./log"

do ->

  input = process.argv[2..].join " "

  try

    [command, options] = parse input

    try
      run command, options ? {}
    catch error
      log.error error

  catch error
    log.error "Unable to parse [#{input}]"
