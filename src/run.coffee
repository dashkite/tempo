import {spawn} from "child_process"
import {resolve} from "path"
import YAML from "js-yaml"
import {unary, flow} from "panda-garden"
import {exist, read} from "panda-quill"
import {promise} from "panda-parchment"
import {stack, peek, push, replace, map, log as _log} from "@dashkite/katana"
import commands from "./commands"
import Package from "./package"
import log from "./log"

yaml = unary YAML.safeLoad

announce = (command, options) ->
  log.info "command: %s", command
  log.info "options: %s", options

# TODO figure out how to do this via stack composition
# the shell combinator handles dealing with rehearse option
clone = (pkg, command, options) ->
  unless await exist pkg.path
    log.info pkg, "git clone from [#{pkg.git}]"
    unless options.rehearse
      promise (resolve, reject) ->
        child = spawn "git",
          [ "clone", "-q", pkg.git, pkg.path ],
          shell: true, inherit: true
        child.on "error", (error) ->
          pkg.errors.push error
          reject error
        child.on "close", (status) ->
          if status != 0
            log.warn pkg, "[git clone] exited with a non-zero status"
          resolve()

command = (pkg, command, options) ->
  try
    commands[ command ] pkg, options
  catch error
    pkg.errors.push error

errors = (pkg, command, options) ->
  if pkg.errors.length  > 0
    for error in pkg.errors
      log.error pkg, error.message
      log.debug pkg, error
    log.warn pkg, "see tempo.log for details on errors"

run = stack flow [
  peek announce
  push -> read resolve "packages.yaml"
  replace yaml
  # TODO we need a stack combinator that can handle this scenario
  #      we onlyl want to replace the top N items of the stack
  #      with M arguments
  ([packages, command, options]) ->
    if options.path?
      [
        [ packages.find ({path}) -> path == options.path ]
        command
        options
      ]
    else
      [ packages, command, options ]
  map flow [
    replace Package.create
    peek clone
    peek command
    peek errors
  ]
]

export default run
