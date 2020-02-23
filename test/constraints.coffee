import assert from "assert"
import {resolve} from "path"
import {read} from "panda-quill"
import colors from "colors/safe"

import {property} from "../src/constraints/combinators"

do ->

  context =
    package: JSON.parse await read resolve "package.json"

  console.log (property "name", "tempo", context)
