import {curry, rtee, flow} from "panda-garden"
import {peek, test} from "@dashkite/katana"
import {squeeze} from "../helpers"
import {chdir, shell, run, write, announce, constraints} from "./combinators"

# TODO run verify constraints at the end to make sure everything updated
update = squeeze flow [

  peek chdir squeeze flow [

    peek announce

    peek constraints

    peek write

  ]

]

export default update
