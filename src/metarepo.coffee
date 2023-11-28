import FS from "node:fs/promises"
import YAML from "js-yaml"
import { log } from "./logger"
import Repos from "./repos"
import Repo from "./repo"
import Configuration from "./configuration"
import GitIgnore from "./git-ignore"
import { expand, isDirectory, run, ignore } from "./helpers"

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

  exec: ( command, args, { include, exclude, tags, groups, serial }) ->
    command = [ command, args... ].join " "
    if groups?
      ignore [ "include", "exclude", "serial" ], 
        { include, exclude, serial }
      groups = await Configuration.Repos.groups groups
      Repos.run groups, command
    else
      repos = await Configuration.Repos.list {
        include
        exclude
        tags
      }
      Repos.run repos, command, { serial }

  run: ( command, args, options ) ->
    { scripts } = await Configuration.load()
    if ( script = scripts?[ command ])?
      Metarepo.exec ( expand script, args ), [], options
    else
      log.error "run script [ #{ command } ] not defined"

  tag: ( tags, options ) ->
    do ({ repo, include, exclude } = options ) ->
      repos = if repo?
        ignore [ "include", "exclude" ], 
          { include, exclude }
        [ await Configuration.Repos.find repo ]
      else
        ignore [ "repo" ], { repo }
        await Configuration.Repos.list { include, exclude }
      if options.delete
        Repos.untag repos, tags
      else
        Repos.tag repos, tags
      Configuration.Repos.update repos

export default Metarepo