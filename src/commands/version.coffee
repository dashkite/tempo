import {curry, rtee, flow} from "panda-garden"
import {peek, test} from "@dashkite/katana"
import {stack} from "../helpers"
import {chdir, shell, run, write, announce, constraints} from "./combinators"

version = stack flow [

  peek chdir stack flow [

    peek announce

    # TODO this should check the flags
    peek shell "npm version patch"

    # TODO do we want to do this?
    peek shell "git push --tags"

    peek run

  ]

]

export default version
