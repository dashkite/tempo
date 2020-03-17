import {curry, tee, flow} from "panda-garden"
import {property, isDefined} from "panda-parchment"
import {stack, push, peek, pop, poke, test,
  apply, log as $log} from "@dashkite/katana"
import {json, nonzero, commit} from "./combinators"
import verify from "./verify"
import exec from "../exec"
import log from "../log"

wildstyle = (pkg, options) -> options.wildstyle?

updates = ({updated}, pkg) ->
    for {name, version} in updated
      log.info pkg, "updated [#{name}] to [#{version}]"

update = stack flow [

  tee flow [
    push exec "npm update --json"
    test nonzero, flow [
      poke property "stdout"
      poke json
      test isDefined, peek updates
    ]
  ]

  # TODO we also want to log output here
  # test wildstyle, peek exec "npx ncu -u"

  commit "tempo update"

  peek verify

]

export default update
