import assert from "assert"
import {print, test, success} from "amen"
import * as _ from "@dashkite/joy"
import * as m from "@dashkite/masonry"

do ->

  print await test "Tempo",  [

    test "basic test", ->
      await m.exec "build/src/bin/tempo", [ "test/test.yaml" ]
  ]

  process.exit if success then 0 else 1
