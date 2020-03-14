import {format} from "util"
import dayjs from "dayjs"
import {binary, curry, tee, rtee, flow} from "panda-garden"
import {stack, push, peek, pop, mpoke, branch, second, log} from "@dashkite/katana"
import {exec} from "./combinators"

major = ({major, wildstyle}) -> major? || wildstyle?
minor = ({minor}) -> minor?

version = stack flow [

  branch [
    [ (second major), push -> "major" ]
    [ (second minor), push -> "minor" ]
    push -> "patch"
  ]
  mpoke binary format "npm version %s"

  pop exec

  peek exec "git push --follow-tags"

]

export default version
