import assert from "assert"
import {print, test, success} from "@dashkite/amen"

import "../src/cli"

do ->

  print await test "Tempo",  []

  process.exit if success then 0 else 1
