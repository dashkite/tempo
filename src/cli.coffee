import winston from "winston"
import {parse} from "../src/parse"
import commands from "../src/commands"

do ->

  [command, options] = parse process.argv[2..].join " "

  packages = YAML.safeLoad await read resolve ".", "packages.yaml"

  # TODO add formats?
  logger = winston.createLogger
    transports: [
      new winston.transports.Console()
      new winston.transports.File
        level: "debug"
        filename: "tempo.log"
    ]

  context = Context.create {command, options, logger}

  for pkg in packages
    # TODO maybe make this into its own graph
    # TODO check for existance of directory
    # TODO conditionally clone repo
    context.project =
      path: resolve p.path
      cache: {}
      updates: []

    commands[command] pkg, context
