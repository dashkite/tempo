import {unary, curry, rtee, flow} from "panda-garden"
import {property, keys} from "panda-parchment"
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
    log.info pkg, "** package verified **"
  else
    log.warn pkg, "results:"
    for error in errors
      log.warn pkg, "- #{error}"
    log.warn pkg, "see tempo.log for details"

verify = stack flow [

  test (scope "dependencies"), flow [

    peek shell "npm audit --json", stack flow [
      replace property "stdout"
      replace json
      peek (result, pkg) ->
        if result.actions.length > 0
          pkg.errors.push "audit failed"
    ]

    peek shell "npm outdated --json", stack flow [
      replace property "stdout"
      replace json
      peek (result, pkg) ->
        if (keys result).length != 0
          pkg.errors.push "update dependencies"
    ]
  ]

  test (scope "build"), flow [
    peek shell "npm ci --colors false"
    peek shell "npm test --colors false", stack flow [
      peek ({status}, pkg) ->
        pkg.errors.push "failing test(s)" if status != 0
    ]
  ]

  peek run

  test (scope "constraints"), flow [
    peek constraints
    peek (pkg) ->
      if (keys pkg.updates).length != 0
        pkg.errors.push "failing constraint(s)"
  ]

  peek report

]

export default verify
