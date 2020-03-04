import {curry, rtee, flow} from "panda-garden"
import {peek, test} from "@dashkite/katana"
import {stack} from "../helpers"
import {chdir, shell, run, write, announce, constraints} from "./combinators"

publish = stack flow [

  peek chdir stack flow [

    peek announce
    peek shell "npm publish --access public"

  ]

]

export default publish
