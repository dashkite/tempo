import {flow} from "panda-garden"
import {peek, stack, log as $log} from "@dashkite/katana"
import {scoped, file, properties} from "../combinators"

export default stack flow [
  peek scoped
  peek properties "package.json",
    scripts: test: "p9k test"
    license: "SEE LICENSE IN LICENSE.md"
    files: [ "./build" ]
    main: "build/npm/src/index.js"
  peek file "LICENSE.md"
  peek file "tasks/index.coffee"
  peek file ".gitignore"
]
