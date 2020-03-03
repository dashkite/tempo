import {curry, rtee, flow} from "panda-garden"
import {peek, test} from "@dashkite/katana"
import {squeeze} from "../helpers"
import {chdir, shell, run, write, announce, constraints} from "./combinators"

scope = curry (name, _, context) ->
  !context.options.scope? || context.options.scope == name

verify = squeeze flow [

  peek chdir squeeze flow [

    peek announce

    test (scope "dependencies"), flow [
      peek shell "npm audit"
      peek shell "npm outdated"
    ]

    test (scope "build"), flow [
      peek shell "npm ci"
      peek shell "npm test"
    ]

    test (scope "constraints"), peek constraints

  ]

]

export default verify
