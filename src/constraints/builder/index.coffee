import {flow} from "panda-garden"
import {first, property} from "panda-parchment"
import {stack, peek, log} from "@dashkite/katana"
import {file} from "../combinators"

export default stack flow [
  peek file "LICENSE.md"
  # TODO this is a bit awkward to have to tack on to each constraint fn
  first
  property "updates"
]
