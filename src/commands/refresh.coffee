import {curry, rtee, flow} from "panda-garden"
import {property} from "panda-parchment"
import {stack, pop, peek, replace, test} from "@dashkite/katana"
import {shell, write, run, constraints} from "./combinators"
import verify from "./verify"

nonzero = ({status}) -> status != 0

# TODO run verify constraints at the end to make sure everything updated
update = stack flow [

  peek constraints

  peek write

  peek shell "git diff-index --quiet HEAD --", stack flow [
    test nonzero, flow [
      pop ->
      peek shell "git add -A ."
      peek shell "git commit -m 'tempo refresh'"
    ]
  ]

  peek verify

]

export default update
