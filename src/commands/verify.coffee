import {curry, rtee, flow} from "panda-garden"
import constraints from "../constraints"
import {shell, run, write, announce} from "./combinators"

scope = curry rtee (name, f, context) ->
  if !context.options.scope? || context.options.scope == name
    f context

export default flow [

  announce

  scope "dependencies", flow [
    shell "npm audit"
    shell "npm outdated"
  ]

  scope "build", flow [
    shell "npm ci"
    shell "npm test"
  ]

  scope "constraints", constraints

  run
  write

]
