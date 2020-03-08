import {binary, curry, flow} from "panda-garden"
import {property} from "panda-parchment"
import {stack, peek, replace, test} from "@dashkite/katana"
import {shell, json, constraints, notify} from "./combinators"
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
          log.warn "audit failed"
    ]

    peek shell "npm outdated --json", stack flow [
      replace property "stdout"
      replace json
      peek (result, pkg) ->
        for name, version of result
          log.warn "update [#{name}] to [#{version.wanted}]"
    ]
  ]

  test (scope "build"), flow [
    peek shell "npm ci --colors false"
    peek shell "npm test --colors false",
      ({status}, pkg) -> log.warn pkg, "failing test(s)" if status != 0
  ]

  test (scope "constraints"),
    peek constraints notify

]

export default verify
