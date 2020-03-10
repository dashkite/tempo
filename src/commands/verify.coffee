import {binary, curry, flow} from "panda-garden"
import {property} from "panda-parchment"
import {stack, push, pop, peek, replace, test, restore, log as $log} from "@dashkite/katana"
import {shell, json, constraints, report} from "./combinators"
import log from "../log"

scope = curry (name, pkg, {scope}) -> !scope? || scope == name

zero = ({status}) -> status == 0
nonzero = ({status}) -> status != 0

# TODO stack should preserve arity ala curry
verify = binary stack flow [

  test (scope "dependencies"), flow [

    restore flow [
      push shell "npm audit --json"
      test zero, flow [
        replace property "stdout"
        replace json
        peek (result, pkg) ->
          if result.actions.length > 0
            log.warn pkg, "audit failed"
        ]
    ]

    restore flow [
      push shell "npm outdated --json"
      test zero, flow [
        replace property "stdout"
        replace json
        peek (result, pkg) ->
          for name, version of result
            log.warn pkg, "update [#{name}] to [#{version.wanted}]"
      ]
    ]
  ]

  test (scope "build"), flow [
    peek shell "npm ci --colors false"
    restore flow [
      push shell "npm test --colors false"
      test nonzero, (result, pkg) ->
        log.warn pkg, "failing test(s)"
    ]
  ]

  test (scope "constraints"), restore flow [
    push constraints
    peek report
  ]

]

export default verify
