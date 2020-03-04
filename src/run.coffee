import {resolve} from "path"
import YAML from "js-yaml"
import {flow} from "panda-garden"
import {read} from "panda-quill"
import {peek, replace} from "@dashkite/katana"
import commands from "./commands"
import log from "./log"
import {map, splat} from "./helpers"

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
  push -> read resolve "."
  replace YAML.safeLoad
  replace Package.create
  map flow [
    peek clone
    peek command
  ]
]

export default run
