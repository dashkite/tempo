import util from "util"
import dayjs from "dayjs"
import {wrap, binary, curry, flow} from "panda-garden"
import {stack, apply, push, peek, pop, poke, test,
  branch, second, log as $log} from "@dashkite/katana"
import exec from "../exec"
import {zero} from "./combinators"

major = apply ({major, wildstyle}) -> major? || wildstyle?
minor = apply ({minor}) -> minor?

format = curry binary util.format

version = stack flow [

  branch [
    [ (second major), push -> "major" ]
    [ (second minor), push -> "minor" ]
    [ (wrap true), push -> "patch"]
  ]

  poke format "npm version %s"
  poke exec

  test zero, flow [
    pop ->
    peek exec "git push --follow-tags"
  ]

]

export default version
