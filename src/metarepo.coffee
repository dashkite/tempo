import FS from "node:fs/promises"
import YAML from "js-yaml"

import Repo from "./repo"
import Configuration from "./configuration"
import GitIgnore from "./git-ignore"
import { command as exec } from "execa"
import chalk from "chalk"

run = ( action ) ->
  exec action, stdout: "inherit", stderr: "inherit", shell: true

isDirectory = ( name ) ->
  try
    ( await FS.stat name ).isDirectory()
  catch
    false

Metarepo =

  add: ( repo ) ->
    { organization, name } = Repo.parse repo
    try
      await Configuration.Repos.add { organization, name }
      await GitIgnore.add name
      await Metarepo.clone()
    catch error
      console.log chalk.red "[tempo] #{error}"
      try
        await Metarepo.remove repo

  remove: ( repo ) ->
    try
      { organization, name } = Repo.parse repo
      await Configuration.Repos.remove { organization, name }
      await GitIgnore.remove name
      await FS.rm name, recursive: true
    catch error
      console.log chalk.red "[tempo] #{error}"
      

  clone: ->
    repos = await Configuration.Repos.list()
    for { organization, name } in repos
      unless await isDirectory name
        await run "git clone git@github.com:#{organization}/#{name}.git"

  import: ( path ) ->
    repos = YAML.load await FS.readFile path, "utf8"
    for repo in repos
      await Metarepo.add repo

export default Metarepo