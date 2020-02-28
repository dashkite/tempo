import winston from "winston"
import {parse} from "../src/parse"
import {run} from "../src/helpers"

do ->

  [command, options] = parse process.argv[2..].join " "

  # TODO add formats?
  logger = winston.createLogger
    transports: [
      new winston.transports.Console()
      new winston.transports.File
        level: "debug"
        filename: "tempo.log"
    ]

  run {command, options, logger}
