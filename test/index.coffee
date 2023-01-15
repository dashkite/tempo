import assert from "assert"
import {print, test, success} from "@dashkite/amen"
import * as _ from "@dashkite/joy"
import { command as exec } from "execa"

do ->

  print await test "Tempo",  [

    test "basic test", wait: false, ->
      await exec "build/node/src/bin/tempo
        --project test/project.yaml
        --actions test/actions.yaml"
  ]

  process.exit if success then 0 else 1
