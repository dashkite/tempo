import assert from "assert"
import {print, test, success} from "amen"

import winston from "winston"
import {parse} from "../src/parse"
import {run} from "../src/helpers"
import commands from "../src/commands"

{combine, label, timestamp, colorize, printf, splat, errors} = winston.format
logger = winston.createLogger
  transports: [ new winston.transports.Console() ]
  format: combine (label label: "tempo"),
    timestamp(),
    splat(),
    (errors stack: true)
    (colorize all: true),
    printf ({level, message}) -> "#{level} - #{message}"

do ->

  print await test "command", [

    test "verify", ->

      [command, options] = parse "rehearse verify"

      [pkg, context] = await commands[command]
        path: "."
        constraints: [ "builder" ]
        actions: []
        updates: {}
        cache:
          content: {}
          data: {}

      ,
        {command, options, logger},

      assert.deepEqual pkg.actions,
        [ 'npm audit', 'npm outdated', 'npm ci', 'npm test' ]
  ]
