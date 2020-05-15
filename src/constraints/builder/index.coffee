import {flow} from "panda-garden"
import {peek, stack, log as $log} from "@dashkite/katana"
import basic from "../basic"
import {scoped, file, properties} from "../combinators"

export default stack flow [
  # TODO do i need to make that binary or something?
  # peek basic
  peek properties "package.json",
    scripts: test: "p9k test"
    files: [ "build/npm/src" ]
    main: "build/npm/src/index.js"
  peek file "tasks/index.coffee"
]
