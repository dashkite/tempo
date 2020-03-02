import winston from "winston"
import {parse} from "../src/parse"
import {run} from "../src/helpers"

{combine, label, timestamp, splat, errors, colorize, printf} = winston.format

# TODO add formats?
logger = winston.createLogger
  transports: [
    new winston.transports.Console()
    new winston.transports.File
      level: "debug"
      filename: "tempo.log"
  ]
  format: combine (label label: "tempo"),
    timestamp(),
    splat(),
    (errors stack: true),
    (colorize all: true),
    printf ({label, level, timestamp, message}) ->
      "#{label} [#{level}] #{timestamp} #{message}"


do ->

  [command, options] = parse process.argv[2..].join " "
  run {command, options, logger}
