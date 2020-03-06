import {unary, curry, rtee, flow} from "panda-garden"
import {keys} from "panda-parchment"
import {stack, peek, replace, test} from "@dashkite/katana"
import {shell, constraints, run} from "./combinators"
import log from "../log"

scope = curry (name, pkg, {scope}) -> !scope? || scope == name

# we need this because JSON.parse is a binary fn
json = unary JSON.parse

results = curry (key, result, pkg) -> pkg.results[key] = result

report = (pkg) ->
  {errors} = pkg
  if (pkg.result ?= (errors.length == 0))
    log.info pkg, "results: package up-to-date, no issues found"
  else
    log.info pkg, "results:"
    for error in errors
      log.info pkg, "- #{error}"
    log.info pkg, "see tempo.log for details"

verify = stack flow [

  test (scope "dependencies"), flow [

    peek shell "npm audit --json", stack flow [
      replace json
      peek (result, pkg) ->
        if result.actions.length > 0
          pkg.errors.push "audit failed"
    ]

    # TODO this exist w non-zero so we never see the report
    #      same is probably true for audit
    #      so we need a way to proceed even on non-zero
    #      maybe put status, stdout, stderr on the stack?
    peek shell "npm outdated --json", stack flow [
      replace json
      peek (result, pkg) ->
        if (keys result).length != 0
          pkg.errors.push "update dependencies"
    ]
  ]

  test (scope "build"), flow [
    peek shell "npm ci --colors false"
    peek shell "npm test --colors false"
  ]

  test (scope "constraints"), peek constraints

  peek run

  peek report

]

export default verify
