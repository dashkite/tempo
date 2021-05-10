import YAML from "js-yaml"
import FS from "fs/promises"
import * as _ from "@dashkite/joy"
import * as m from "@dashkite/masonry"

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
  for path in description.paths
    process.chdir path
    for action in description.actions
      [ command, args... ] = _.words action
      {exitCode} = await m.exec command, args
      if exitCode != 0
        process.chdir wd
        process.exit 1

    process.chdir wd
