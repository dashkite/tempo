import {binary, curry, flow, tee} from "panda-garden"
import {property} from "panda-parchment"
import {stack, push, pop, peek, poke, test, log as $log} from "@dashkite/katana"
import {json, exemplars, report, zero, nonzero} from "./combinators"
import exec from "../exec"
import log from "../log"

scope = curry (name, pkg, {scope}) -> !scope? || scope == name

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
    # TODO this really slows things down ...
    #      maybe make it optional somehow?
    peek exec "npm ci --colors false"
    tee flow [
      push exec "npm test --colors false"
      test nonzero, peek (result, pkg) ->
        log.warn pkg, "failing test(s)"
    ]
  ]

  test (scope "exemplars"), peek exemplars

  peek report

]

export default verify
