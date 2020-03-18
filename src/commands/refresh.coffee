import {curry, rtee, flow} from "panda-garden"
import {property} from "panda-parchment"
import {stack, push, pop, peek, poke, test, log} from "@dashkite/katana"
import {constraints, write, commit} from "./combinators"
import verify from "./verify"

update = stack flow [

  peek constraints

  peek write

  # TODO this is a reusable stack flow, not a true combinator
  #      maybe import from a different file?
  commit "tempo refresh"

  peek verify

]

export default update
