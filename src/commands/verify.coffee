import {unary, curry, rtee, flow} from "panda-garden"
import {stack, peek, test} from "@dashkite/katana"
import {shell, constraints} from "./combinators"

scope = curry (name, pkg, {scope}) -> !scope? || scope == name

# we need this because JSON.parse is a binary fn
json = unary JSON.parse

results = curry (key, result, pkg) -> pkg.results[key] = result

verify = stack flow [

  test (scope "dependencies"), flow [

    peek shell "npm audit --json", flow [
      peek json
      peek results "audit"
    ]

    peek shell "npm outdated --json", stack flow [
      peek json
      peek results "outdated"
    ]
  ]

  test (scope "build"), flow [

    peek shell "npm ci"
    peek shell "npm test"
  ]

  test (scope "constraints"), peek constraints

]

export default verify
