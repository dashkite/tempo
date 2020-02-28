import {resolve} from "path"
import {flow} from "panda-garden"
import {peek, replace} from "@dashkite/katana"
import YAML from "js-yaml"
import {read} from "panda-quill"

spread = (args...) -> args

map = (stack) ->

run = flow [
  spread
  push -> read resolve "."
  replace YAML.safeLoad
  map flow [
    peek initialize
    peek clone
    peek command
  ]
]

export {run}
