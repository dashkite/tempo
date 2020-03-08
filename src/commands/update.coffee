import {curry, flow} from "panda-garden"
import {property, isDefined} from "panda-parchment"
import {stack, push, peek, pop, replace, test, restore, log as $log} from "@dashkite/katana"
import {shell, json, commit} from "./combinators"
import verify from "./verify"
import log from "../log"

wildstyle = (pkg, options) -> options.wildstyle?

updates = ({updated}, pkg) ->
    for {name, version} in updated
      log.info pkg, "updated [#{name}] to [#{version}]"

update = stack flow [

  restore flow [
    push shell "npm update --json"
    replace property "stdout"
    replace json
    test isDefined, peek updates
  ]

  test wildstyle, peek shell "npx ncu -u"

  commit "tempo update"

  peek verify

]

export default update
