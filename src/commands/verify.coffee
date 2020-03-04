import {curry, rtee, flow} from "panda-garden"
import {stack, peek, test} from "@dashkite/katana"
import {shell, constraints} from "./combinators"

scope = curry (name, pkg, {scope}) -> !scope? || scope == name

verify = stack flow [

  test (scope "dependencies"), flow [
    peek shell "npm audit"
    peek shell "npm outdated"
  ]

  test (scope "build"), flow [
    peek shell "npm ci"
    peek shell "npm test"
  ]

  test (scope "constraints"), peek constraints

]

export default verify
