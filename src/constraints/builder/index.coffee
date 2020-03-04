import {flow} from "panda-garden"
import {stack, peek} from "@dashkite/katana"
import {file} from "../combinators"

export default stack flow [
  peek file "LICENSE.md"
]
