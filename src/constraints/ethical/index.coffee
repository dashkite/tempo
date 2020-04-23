import {flow} from "panda-garden"
import {peek, stack, log as $log} from "@dashkite/katana"
import {scoped, file, properties} from "../combinators"

export default stack flow [
  peek properties "package.json",
    license: "SEE LICENSE IN LICENSE.md"
  peek file "LICENSE.md"
]
