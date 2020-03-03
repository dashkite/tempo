import {flow} from "panda-garden"
import {peek} from "@dashkite/katana"
import {file} from "../combinators"
import {squeeze} from "../../helpers"

export default squeeze flow [
  peek file "LICENSE.md"
]
