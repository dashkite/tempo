import FS from "node:fs/promises"

import YAML from "js-yaml"
import { command as exec } from "execa"

import { log } from "./logger"
import Repo from "./repo"
import Configuration from "./configuration"
import GitIgnore from "./git-ignore"

# TODO make variable substition more robust
# TODO remove this feature in favor of env vars?
expand = ( text, argv ) ->
  text
    .replaceAll /\$(\d)/g, ( _, i ) ->
      if argv[i]?
        argv[i]
      else
        throw new Error "tempo: missing positional argument $#{i}"
    .replaceAll /\$@/g, -> argv.join " "

run = ( action, options ) ->
  exec action, 
    { stdout: "inherit", stderr: "inherit", shell: true, options... }

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
      await GitIgnore.configure()
      await Metarepo.sync()
    catch error
      log.error error
      try
        await Metarepo.remove repo

  remove: ( repo ) ->
    try
      { organization, name } = Repo.parse repo
      await Configuration.Repos.remove { organization, name }
      await FS.rm name, recursive: true
    catch error
      log.error error
  
  clone: ( metarepo ) ->
    { organization, name } = Repo.parse metarepo
    await run "git clone
      git@github.com:#{ organization }/#{ name }.git"
    cwd = process.cwd()
    process.chdir name
    await Metarepo.sync()
    process.chdir cwd

  # TODO: remove, archive, or warn about directories that aren't listed?
  sync: ->
    await run "git pull"
    repos = await Configuration.Repos.list()
    await FS.mkdir ".tempo", recursive: true
    for { organization, name } in repos
      unless await isDirectory ".tempo/#{ name }"
        try
          await run "git clone 
            git@github.com:#{ organization }/#{ name }.git
            .tempo/#{ name }"
          await run "ln -sf .tempo/#{ name }"
        catch error
          log.error error

  import: ( path ) ->
    repos = YAML.load await FS.readFile path, "utf8"
    for repo in repos
      await Metarepo.add repo

  exec: ( command, args, { targets }) ->
    command = [ command, args... ].join " "
    repos = await Configuration.Repos.list targets
    for { name } in repos
      log
        .scope name
        .info command
      try
        await run command, cwd: name
      catch error
        log
          .scope name
          .error error.message

  run: ( command, args, { targets }) ->
    { scripts } = await Configuration.load()
    if ( script = scripts?[ command ])?
      repos = await Configuration.Repos.list targets
      for { name } in repos
        log
          .scope name
          .info command
        try
          await run ( expand script, args ), cwd: name
        catch error
          log
            .scope name
            .error error.message
    else
      log.error "run script [ #{ command } ] not defined"

export default Metarepo