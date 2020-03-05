import {resolve} from "path"
import YAML from "js-yaml"
import {unary, flow} from "panda-garden"
import {read} from "panda-quill"
import {stack, peek, push, replace, map, log as _log} from "@dashkite/katana"
import commands from "./commands"
import Package from "./package"
import log from "./log"

yaml = unary YAML.safeLoad

announce = (command, options) ->
  log.info "command: %s", command
  log.info "options: %s", options

clone = ({path, git}) ->
  # check if file exists, otherwise clone repo
  # do we clone if rehearse is true?

command = (pkg, command, options) ->
  commands[ command ] pkg, options

run = stack flow [
  peek announce
  push -> read resolve "packages.yaml"
  replace yaml
  map flow [
    replace Package.create
    peek clone
    peek command
  ]
]

export default run
