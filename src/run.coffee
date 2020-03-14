import {resolve} from "path"
import YAML from "js-yaml"
import {unary, flow, wrap} from "panda-garden"
import {isDefined} from "panda-parchment"
import {exist, read} from "panda-quill"
import {cover, stack,
  peek, push, poke, test, branch,
  third, over,
  log as $log} from "@dashkite/katana"
import {each} from "panda-river"
import commands from "./commands"
import Package from "./package"
import exec from "./exec"
import log from "./log"

yaml = unary YAML.safeLoad

announce = (command, options) ->
  log.info "command: %s", command
  log.info "options: %s", options

clone = (pkg, _, options) ->
  unless await exist pkg.path
    exec "git clone -q #{pkg.git} #{pkg.path}", pkg, options

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

readPackages = flow [
  wrap resolve "packages.yaml"
  read
  yaml
]

# TODO we need an iterable variant for this
find = (predicate, array) -> array.find predicate

findPackage = (packages, _, options) ->
  find ((pkg) -> pkg.path == options.path), packages

runPackage = flow [
  poke Package.create
  peek clone
  peek command
  peek errors
]

run = stack flow [
  peek announce
  push readPackages
  branch [
    # if command referenced a specific package, find and run it
    [
      # stack: [ packages, command, options ]
      third cover (options) -> options.path?
      flow [
        poke findPackage
        test isDefined, runPackage
      ]
    ]
    # else run each package
    over each runPackage
  ]
]

export default run
