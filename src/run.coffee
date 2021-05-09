import {resolve} from "path"
import YAML from "js-yaml"
import {unary, pipe, flow, wrap, tee} from "panda-garden"
import {property, cat, isDefined} from "panda-parchment"
import {exist, read} from "panda-quill"
import {apply, stack,
  peek, push, poke, test, branch,
  third, over,
  log as $log} from "@dashkite/katana"
import {wait, map, each, reduce} from "panda-river"
import {use, Fetch, from, url, method, request, text} from "@dashkite/mercury"
import fetch from "node-fetch"
import commands from "./commands"
import Package from "./package"
import Exemplar from "./exemplar"
import exec from "./exec"
import log from "./log"

yaml = unary YAML.safeLoad

# TODO get rid of this once Mercury supports native Node HTTP client
global.fetch = fetch

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

addExemplar = ([name, module]) ->
  # await exec "npm i #{module}"
  Exemplar.create name, module

loadIndex = flow [
  # TODO shouldn't need to provide mode option
  use Fetch.client mode: "cors"
  from [
    property "data"
    url
  ]
  method "get"
  request
  text
  property "text"
  yaml
]

readPackages = flow [
  wrap resolve process.env.HOME, "./.tempo"
  read
  yaml
  property "indices"
  wait map loadIndex
  reduce cat, []
]

# TODO we need an iterable variant for this
find = (predicate, array) -> array.find predicate

findPackage = (packages, _, options) ->
  find ((pkg) -> pkg.path == options.path), packages

runPackage = flow [
  poke Package.create
  peek flow [
    property "exemplars"
    Object.entries
    each addExemplar
  ]
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
      third apply (options) -> options.path?
      flow [
        poke findPackage
        test isDefined, runPackage
      ]
    ]
    # else run each package
    [
      wrap true
      over each runPackage
    ]
  ]
]

export default run
