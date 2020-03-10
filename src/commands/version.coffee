import dayjs from "dayjs"
import {curry, tee, rtee, flow} from "panda-garden"
import {stack, push, peek, pop, replace, restore, log} from "@dashkite/katana"
import {shell} from "./combinators"


version = stack flow [

  restore flow [

    push (pkg, {major, minor, wildstyle}) ->
      if major || wildstyle
        "npm version major"
      else if minor
        "npm version minor"
      else
        "npm version patch"

    peek shell

  ]

  peek shell "git push --follow-tags"

]

export default version
