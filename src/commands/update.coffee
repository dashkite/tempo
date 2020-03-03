import {curry, rtee, flow} from "panda-garden"
import {peek, test} from "@dashkite/katana"
import {squeeze} from "../helpers"
import {chdir, shell, run, write, announce, constraints} from "./combinators"

wildstyle = curry (_, context) ->
  context.options.wild?

# TODO run verify at the end to make sure everything updated
update = squeeze flow [

  peek chdir squeeze flow [

    peek announce

    peek shell "npm update"

    test wildstyle, peek shell "npx ncu -u"

    peek run
    peek write

  ]

]

export default update