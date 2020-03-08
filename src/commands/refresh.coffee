import {curry, rtee, flow} from "panda-garden"
import {property} from "panda-parchment"
import {stack, pop, peek, replace, test} from "@dashkite/katana"
import {shell, commit, constraints, write} from "./combinators"
import verify from "./verify"

update = stack flow [

  peek constraints write

  peek commit

  peek verify

]

export default update
