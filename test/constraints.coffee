import assert from "assert"
import {resolve} from "path"
import {read} from "panda-quill"
import colors from "colors/safe"

import {file, property} from "../src/constraints/combinators"

do ->

  console.log colors.green "Property Constraint"

  context =
    refresh: false
    project:
      path: resolve "."
    constraint:
      path: resolve "test", "files"
    updates: {}
    data: {}
    messages:
      info: []
      warn: []
      fatal: []


  assert (await property "package.json", "name", "tempo", context)
    ?.updates?["package.json"]?

  assert.equal 1,
    (await property "package.json", "scripts.test", "p9k test", context)
    ?.messages?.info?.length

  assert.equal 1,
    (await property "package.json", "scripts.fubar", "p9k test", context)
    ?.messages?.warn?.length

  assert (await file "LICENSE.md", context)
    ?.updates?["LICENSE.md"]?

  assert 2, (await file "missing-file", context)
    ?.messages?.warn?.length


  console.log colors.green "  Verify"
