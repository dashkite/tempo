import {curry, flow} from "panda-garden"
import {property, isDefined} from "panda-parchment"
import {stack, push, peek, pop, poke, test, log as $log} from "@dashkite/katana"
import {exec, json, commit} from "./combinators"
import verify from "./verify"
import log from "../log"

wildstyle = (pkg, options) -> options.wildstyle?

updates = ({updated}, pkg) ->
    for {name, version} in updated
      log.info pkg, "updated [#{name}] to [#{version}]"

update = stack flow [

  push exec "npm update --json"
  poke property "stdout"
  poke json
  test isDefined, pop updates

  # TODO we also want to log output here
  # test wildstyle, peek exec "npx ncu -u"

  commit "tempo update"

  peek verify

]

export default update
