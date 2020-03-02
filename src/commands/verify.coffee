import {curry, rtee, flow} from "panda-garden"
import {peek, test} from "@dashkite/katana"
import {chdir as _chdir} from "panda-quill"
import constraints from "../constraints"
import {squeeze} from "../helpers"
import {shell, run, write, announce} from "./combinators"

chdir = curry (f, pkg, context) ->
  _chdir pkg.path, -> f pkg, context

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
