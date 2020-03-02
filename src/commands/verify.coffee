import {curry, rtee, flow} from "panda-garden"
import {peek, test} from "@dashkite/katana"
import {chdir as _chdir} from "panda-quill"
import {squeeze} from "../helpers"
import {shell, run, write, announce, constraints} from "./combinators"

# TODO quill/chdir should support async fn
chdir = curry (f, pkg, context) ->
  cwd = process.cwd()
  process.chdir pkg.path
  f pkg, context

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

    peek run
    peek write

  ]

]

export default verify
