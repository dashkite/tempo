import {curry, rtee, flow} from "panda-garden"
import {property} from "panda-parchment"
import {stack, push, pop, peek, poke, test, log} from "@dashkite/katana"
import {constraints, write, commit} from "./combinators"
import verify from "./verify"

# TODO should we have verify run before the commit?
#      and then we conditionally commit based on the results

update = stack flow [

  peek constraints

  peek write

  # TODO this is a reusable stack flow, not a true combinator
  #      maybe import from a different file?
  commit "tempo refresh"

  peek verify

]

export default update
