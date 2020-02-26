import assert from "assert"
import {print, test, success} from "amen"

import {parse} from "../src/parse"
import commands from "../src/commands"

do ->
  print await test "command", [

    test "verify", ->

      [command, options] = parse "tempo rehearse verify constraints"
      commands[command] options

  ]
