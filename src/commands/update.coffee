import {curry, flow} from "panda-garden"
import {property, isDefined} from "panda-parchment"
import {stack, peek, replace, test} from "@dashkite/katana"
import {shell, json, run, report} from "./combinators"
import verify from "./verify"
import log from "../log"

wildstyle = curry (_, options) -> options.wildstyle?

# TODO run verify at the end to make sure everything updated
update = stack flow [

  peek shell "npm update --json", stack flow [
    replace property "stdout"
    replace json
    test isDefined, peek ({updated}, pkg) ->
      for {name, version} in updated
        log.info pkg, "updated [#{name}] to [#{version}]"
  ]

  test wildstyle, peek shell "npx ncu -u"

  # don't need to run report since we run it in verify
  # TODO perhaps have verify take report: false as an option?
  peek verify

]

export default update
