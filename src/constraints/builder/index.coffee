import {flow} from "panda-garden"
import {peek, log as $log} from "@dashkite/katana"
import {constraint, file, properties} from "../combinators"

export default constraint flow [
  peek file "LICENSE.md"
  peek properties "package.json",
    scripts: test: "p9k test"
    license: "SEE LICENSE IN LICENSE.md"
    files: [ "./build" ]
]
