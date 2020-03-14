import dayjs from "dayjs"
import {curry, tee, rtee, flow} from "panda-garden"
import {stack, push, peek, pop, poke, test, log} from "@dashkite/katana"
import {exec} from "./combinators"

publish = stack flow [

  # TODO use separate subgraph to conditionally initialize commit/publish
  poke tee (pkg) ->
    pkg.last =
      commit: dayjs.unix 0
      publish: dayjs.unix 0

  # TODO this should check the flags
  push exec "git log -1 --format=%aI origin/master"
  test (({status}) -> status == 0),
    poke rtee ({stdout}, pkg) -> pkg.last.commit = dayjs stdout

  push exec "npm view . time.modified"
  test (({status}) -> status == 0),
    poke rtee ({stdout}, pkg) -> pkg.last.publish = dayjs stdout

  test ((pkg) -> pkg.last.commit.isAfter pkg.last.publish), flow [
    peek exec "npm publish --access public"
  ]


]

export default publish
