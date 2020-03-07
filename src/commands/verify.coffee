import {binary, curry, flow} from "panda-garden"
import {property} from "panda-parchment"
import {stack, peek, replace, test} from "@dashkite/katana"
import {shell, json, constraints, run, report} from "./combinators"
import log from "../log"

scope = curry (name, pkg, {scope}) -> !scope? || scope == name

# TODO stack should preserve arity ala curry
verify = binary stack flow [

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
        for name, version of result
          pkg.errors.push "update [#{name}] to [#{version.wanted}]"
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
      for path, _ of pkg.updates
        pkg.errors.push "[#{path}] needs updating"
  ]

  peek report

]

export default verify
