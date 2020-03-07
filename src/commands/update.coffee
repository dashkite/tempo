import {curry, flow} from "panda-garden"
import {property, isDefined} from "panda-parchment"
import {stack, peek, replace, test} from "@dashkite/katana"
import {shell, json, run, report} from "./combinators"
import log from "../log"

wildstyle = curry (_, options) -> options.wildstyle?

# TODO run verify at the end to make sure everything updated
update = stack flow [

  peek shell "npm update --json", stack flow [
    replace property "stdout"
    # TODO sometimes this is '' which gives us an error
    replace json
    test isDefined, peek ({updated}, pkg) ->
      for {name, version} in updated
        log.info pkg, "updated [#{name}] to [#{version}]"
  ]

  test wildstyle, peek shell "npx ncu -u"

  peek run

  peek report

]

export default update
