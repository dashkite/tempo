import dayjs from "dayjs"
import {tee, flow} from "panda-garden"
import {property} from "panda-parchment"
import {push, peek, pop, poke, test,
  stack, apply, log as $log} from "@dashkite/katana"
import exec from "../exec"
import {zero} from "./combinators"

publish = apply (pkg) -> pkg.last.commit.isAfter pkg.last.publish

publish = stack flow [

  # TODO use separate subgraph to conditionally initialize commit/publish
  peek (pkg) ->
    pkg.last =
      commit: dayjs.unix 0
      publish: dayjs.unix 0

  # TODO this should check the flags
  tee flow [
    push exec "git log -1 --format=%aI origin/master"
    test zero, flow [
      poke property "stdout"
      peek (stdout, pkg) -> pkg.last.commit = dayjs stdout
    ]
  ]

  tee flow [
    push exec "npm view . time.modified"
    test zero, flow [
      poke property "stdout"
      peek (stdout, pkg) -> pkg.last.publish = dayjs stdout
    ]
  ]

  test publish, peek exec "npm publish --access public"

]

export default publish
