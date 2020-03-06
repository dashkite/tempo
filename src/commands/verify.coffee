import {unary, curry, rtee, flow} from "panda-garden"
import {stack, peek, test, log} from "@dashkite/katana"
import {shell, constraints, run, report} from "./combinators"

scope = curry (name, pkg, {scope}) -> !scope? || scope == name

# we need this because JSON.parse is a binary fn
json = unary JSON.parse

results = curry (key, result, pkg) -> pkg.results[key] = result

verify = stack flow [

  test (scope "dependencies"), flow [

    peek shell "npm audit --json", stack flow [
      peek json
      peek results "audit"
    ]

    peek shell "npm outdated --json", stack flow [
      peek json
      peek results "outdated"
    ]
  ]

  test (scope "build"), flow [
    peek shell "npm ci --colors false"
    peek shell "npm test --colors false"
  ]
  #
  # test (scope "constraints"), peek constraints

  peek run

  # TODO how to report on the results of the audit/outdated?
  # TODO does reporting even belong here? or is that up to the caller?
  # TODO should we produce a return value? success/failure?
  peek report

]

export default verify
