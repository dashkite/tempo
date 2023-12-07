import FS from "node:fs/promises"
import Path from "node:path"
import Crypto from "node:crypto"
import { convert } from "@dashkite/bake"
import log from "@dashkite/kaiko"

import { Repo, Repos, GitIgnore, Script, FSX } from "./helpers"
import Progress from "./helpers/progress"

truncate = ( length, text ) -> text[ 0...length ]

# non-destructive sort
sort = ( array ) -> [ array... ].sort()

Key =

  hash: ( vector ) ->
    truncate 8, convert from: "bytes", to: "base36",
      new Uint8Array do ->
        Crypto
          .createHash "md5"
          .update JSON.stringify vector
          .digest()
          .buffer

  make: ({ script, command, args, tags, include, exclude }) ->
    tags ?= []
    include ?= []
    exclude ?= []
    vector = []
    if script?
      vector.push "script"
      vector.push script
    else
      vector.push "command"
      vector.push command

    vector.push args
    vector.push sort tags
    vector.push sort include
    vector.push sort exclude
    Key.hash vector

Metarepo =

  Paths:

    root: ".tempo"

    repos: Path.join ".tempo", "repos"

  resolve: ( name ) ->
    Path.join Metarepo.Paths.repos, name

  git: ({ organization, name }) ->
    "git@github.com:#{ organization }/#{ name }.git"

  add: ( repo ) ->
    { organization, name } = Repo.parse repo
    try
      await Repos.add { organization, name }
      await Metarepo.sync()
    catch error
      log.error error
      try
        await Metarepo.remove repo

  remove: ( repo ) ->
    try
      { organization, name } = Repo.parse repo
      Repos.remove { organization, name }
      await FS.rm ( Metarepo.resolve name ), recursive: true
      await FS.rm name
    catch error
      log.error error
  
  clone: ( metarepo, { branch }) ->
    { organization, name } = Repo.parse metarepo
    git = Metarepo.git { organization, name }
    await Script.run "git clone #{ git }"
    cwd = process.cwd()
    process.chdir name
    await FS.mkdir Metarepo.Paths.repos, recursive: true
    if branch?
      await Script.run "git switch #{ branch }"
    await Metarepo.sync()
    process.chdir cwd

  sync: ->
    await Script.run "git pull"
    await GitIgnore.add Metarepo.Paths.repos
    # TODO handle case where there's no repos.yaml
    repos = await Repos.load()
    progress = Progress.make 
      title: "Cloning Repos"
      count: repos.length
    do progress.start
    for { organization, name } in repos
      unless await FSX.isDirectory Metarepo.resolve name
        git = Metarepo.git { organization, name }
        path = Metarepo.resolve name
        try
          await Script.run "git clone #{ git } #{ path }"
          await Script.run "ln -sf #{ path }"
        catch error
          log.error error
      do progress.increment
    do progress.stop
    do Metarepo.prune

  prune: ->
    paths = await FS.readdir Metarepo.Paths.root
    progress = Progress.make
      title: "Pruning Repos"
      count: paths.length
    do progress.start
    for path in paths
      if await FSX.isDirectory path
        name = Path.basename path
        if !( repo = await Repos.get name )?
          if !( await Repo.changed name )
            try
              await FS.rm path, recursive: true
              await FS.rm path
            catch error
              log.error error
          else
            log.warn "Unable to prune #{ name }
              because it has changes"
      do progress.increment
    do progress.stop

  import: ( path ) ->
    repos = await Zephyr.read path
    for repo in repos
      await Metarepo.add repo

  exec: ( command, args, { include, exclude, tags, options...}) ->
    repos = await Repos.find { include, exclude, tags }
    key = Key.make { command, args, include, exclude, tags }
    length: repos.length
    reactor: await Repos.run { repos, command, args, key, options... }

  run: ( script, args, { include, exclude, tags, options...}) ->
    repos = await Repos.find { script, include, exclude, tags }
    key = Key.make { script, args, include, exclude, tags }
    length: repos.length
    reactor: await Repos.run { repos, script, args, key, options... }

  tag: ( tags, { repos, include, exclude }) ->
    repos = await Repos.find { repos, include, exclude }
    Repos.tag repos, tags
      
  untag: ( tags, { repos, include, exclude }) ->
    repos = await Repos.find { repos, include, exclude }
    Repos.untag repos, tags
      
export default Metarepo