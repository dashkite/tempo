import {binary, curry, flow} from "panda-garden"
import {property} from "panda-parchment"
import {stack, push, pop, peek, poke, test, tee, log as $log} from "@dashkite/katana"
import {json, constraints, report} from "./combinators"
import exec from "../exec"
import log from "../log"

scope = curry (name, pkg, {scope}) -> !scope? || scope == name

zero = ({status}) -> status == 0
nonzero = ({status}) -> status != 0

# TODO stack should preserve arity ala curry
verify = binary stack flow [

  test (scope "dependencies"), flow [

    tee flow [
      push exec "npm audit --json"
      test zero, flow [
        poke property "stdout"
        poke json
        peek (result, pkg) ->
          if result.actions.length > 0
            log.warn pkg, "audit failed"
        ]
    ]

    tee flow [
      push exec "npm outdated --json"
      test zero, flow [
        poke property "stdout"
        poke json
        peek (result, pkg) ->
          for name, version of result
            log.warn pkg, "update [#{name}] to [#{version.wanted}]"
      ]
    ]
  ]

  test (scope "build"), flow [
    peek exec "npm ci --colors false"
    tee flow [
      push exec "npm test --colors false"
      test nonzero, (result, pkg) ->
        log.warn pkg, "failing test(s)"
    ]
  ]

  test (scope "constraints"), tee flow [
    push constraints
    peek report
  ]

]

export default verify
