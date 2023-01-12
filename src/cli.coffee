import FS from "node:fs/promises"
import Path from "node:path"

import YAML from "js-yaml"

import * as _ from "@dashkite/joy"

import { command as exec } from "execa"
import chalk from "chalk"

import usage from "./usage"
import getOptions from "./options"

yaml = ( path ) -> 
  try
    YAML.load await FS.readFile path, "utf8"
  catch
    fatal "unable to read file '#{ path }'"

run = ( action ) ->
  exec action, stdout: "inherit", stderr: "inherit", shell: true

clone = ( organization, path ) ->
  console.error chalk.blue "[tempo] [#{path}] not found, running [git clone]"
  run "git clone git@github.com:#{organization}/#{path}.git"

chdir = ( organization, path ) ->
  try
    process.chdir path
  catch error
    switch error.code
      when "ENOENT"
        if organization?
          await clone organization, path
          process.chdir path
        else
          throw error
      else
        throw error

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

    description = Object.assign {}, 
      ( await yaml options.actions ),
      ( await yaml options.project )

  wd = process.cwd()    

  checkoutRepo = (path) ->
    clone = "git@github.com:#{description.organization}/#{path}.git"
    args = [ "clone", clone ]
    console.error chalk.blue "[tempo] [#{path}] git clone #{clone}"
    await execa "git", args, stdout: "inherit", stderr: "inherit"

  recoveryAttempt = (path) ->
    return false if !description.organization?
    try
      await checkoutRepo path
      process.chdir path
      true
    catch
      false

  for name, value of description.env
    process.env[name] = value

  for path in description.paths
    try
      await chdir description.organization, path
    catch error
      console.error (chalk.red "[tempo] [#{path}]"), chalk.red error.message
      continue

    for action in description.actions

      if _.isObject action
        { command, args } = action
        action = "#{command} #{_.join ' ', args}"

      console.error chalk.blue "[tempo] [#{path}] #{action}"

      try
        await run action
      catch error
        if error.exitCode? && error.exitCode != 0
          console.error chalk.red "[tempo] [#{path}]
            exited with non-zero exit code #{error.exitCode}"
        else
          console.error (chalk.red "[tempo] [#{path}]"),
            chalk.yellow error.message

        process.chdir wd
        break

    process.chdir wd
