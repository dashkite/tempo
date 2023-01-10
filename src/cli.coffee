import FS from "node:fs/promises"
import Path from "node:path"

import YAML from "js-yaml"

import * as _ from "@dashkite/joy"

import execa from "execa"
import chalk from "chalk"

import usage from "./usage"
import getOptions from "./options"

yaml = ( path ) -> 
  try
    YAML.load await FS.readFile path, "utf8"
  catch
    fatal "unable to read file '#{ path }'"

do ->
  
  description = {}
  options = getOptions()

  if options.path?
    
    description = await yaml options.path
    root = Path.dirname path
  
    description.paths ?= if Path.isAbsolute description.projects
      await yaml description.project
    else
      await yaml Path.join root, description.project
  
  else

    description = await yaml options.actions
    description.paths = await yaml options.project

  wd = process.cwd()

  for name, value of description.env
    process.env[name] = value

  for path in description.paths

    try
      process.chdir path
    catch error
      console.error (chalk.red "[tempo] [#{path}]"), chalk.yellow error.message
      continue

    for action in description.actions

      if _.isString action
        [ command, args... ] = _.words action
      else
        { command, args } = action
        action = "#{command} #{_.join ' ', args}"

      console.error chalk.blue "[tempo] [#{path}] #{action}"

      try
        await execa command, args, stdout: "inherit", stderr: "inherit"
      catch error
        if error.exitCode? && error.exitCode != 0
          console.error chalk.red "[tempo] [#{path}]
            exited with non-zero exit code #{error.exitCode}"
        console.error (chalk.red "[tempo] [#{path}]"),
          chalk.yellow error.message

    process.chdir wd
