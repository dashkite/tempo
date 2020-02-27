import assert from "assert"
import {print, test, success} from "amen"

import winston from "winston"
import {parse} from "../src/parse"
import commands from "../src/commands"

do ->

  logger = winston.createLogger()

  print await test "command", [

    test "verify", ->

      [command, options] = parse "tempo rehearse verify constraints"
      context = Context.create {command, options, logger}

      await commands[command] Context.package context,
        path: "."
        constraints: [ "test" ]

  ]
