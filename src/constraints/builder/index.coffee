import {flow} from "panda-garden"
import {first, property as _property} from "panda-parchment"
import {stack, peek, log as $log} from "@dashkite/katana"
import {file, property} from "../combinators"

export default stack flow [
  peek file "LICENSE.md"
  peek property "package.json",
    scripts: test: "p9k test"
    license: "SEE LICENSE IN LICENSE.md"
    files: [ "./build" ]
  # TODO this is a bit awkward to have to tack on to each constraint fn
  first
  _property "updates"
]
