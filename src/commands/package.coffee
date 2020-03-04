import {curry, rtee, flow} from "panda-garden"
import {peek, test} from "@dashkite/katana"
import {stack} from "../helpers"
import {chdir, shell, run, write, announce, constraints} from "./combinators"

pkg = stack flow [

  peek chdir stack flow [

    peek announce

  ]

]

export default pkg
