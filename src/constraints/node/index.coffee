import {flow} from "panda-garden"
import {peek, stack, log as $log} from "@dashkite/katana"
import {scoped, file, noLocalDependencies} from "../combinators"

export default stack flow [
  peek scoped
  peek file ".gitignore"
  peek noLocalDependencies
]
