import {flow} from "panda-garden"
import {peek, stack, log as $log} from "@dashkite/katana"
import node from "../node"
import {scoped, file, properties} from "../combinators"

export default stack flow [
  peek node
  peek properties "package.json",
    scripts: test: "p9k test"
    files: [ "./build" ]
    main: "build/npm/src/index.js"
  peek file "tasks/index.coffee"
]
