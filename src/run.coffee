import {resolve} from "path"
import YAML from "js-yaml"
import {flow} from "panda-garden"
import {read} from "panda-quill"
import {peek, replace} from "@dashkite/katana"
import commands from "./commands"
import {map, splat} from "./helpers"

initialize = ({path, git, constraints}) ->
  {path, git, constraints, cache: {}, updates: []}

clone = ({path, git}) ->
  # check if file exists, otherwise clone repo
  # do we clone if rehearse is true?

command = (pkg, context) ->
  commands[ context.command ] pkg, context

run = splat flow [
  push -> read resolve "."
  replace YAML.safeLoad
  map flow [
    peek initialize
    peek clone
    peek command
  ]
]

export default run
