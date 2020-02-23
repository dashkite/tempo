import assert from "assert"
import {resolve} from "path"
import {read} from "panda-quill"
import colors from "colors/safe"

import {property} from "../src/constraints/combinators"

do ->

  console.log colors.green "Property Constraint"

  context =
    refresh: false
    package: JSON.parse await read resolve "package.json"
    constraints: []

  assert (property "name", "tempo", context).constraints[0]?.success?
  assert (property "scripts.test", "p9k test", context).constraints[1]?.success?
  assert (property "scripts.fubar", "p9k test", context).constraints[2]?.failure?
  # assert (property "scripts.test", "p9k test", context)
  # console.log (property "scripts.foo", "p9k test", context)
