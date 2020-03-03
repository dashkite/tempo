import {curry, rtee, flow} from "panda-garden"
import {peek, test} from "@dashkite/katana"
import {squeeze} from "../helpers"
import {chdir, shell, run, write, announce, constraints} from "./combinators"

pkg = squeeze flow [

  peek chdir squeeze flow [

    peek announce

  ]

]

export default pkg
