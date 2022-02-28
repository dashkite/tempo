import YAML from "js-yaml"
import FS from "fs/promises"
import * as _ from "@dashkite/joy"
import execa from "execa"
import chalk from "chalk"


do ->

  [ path ] = process.argv[2..]

  if path?
    try
      description = YAML.load await FS.readFile path, "utf8"
    catch
      console.error "tempo: unable to read file '#{path}'"
      process.exit 1
  else
    console.error "tempo: usage: tempo <file>"
    process.exit 1

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
      process.chdir path
    catch error
      if !( await recoveryAttempt path )
        console.error (chalk.red "[tempo] [#{path}]"), 
        chalk.yellow error.message
        process.chdir wd
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
        else
          console.error (chalk.red "[tempo] [#{path}]"),
            chalk.yellow error.message

        process.chdir wd
        break

    process.chdir wd
