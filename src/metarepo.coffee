import FS from "node:fs/promises"
import Path from "node:path"
import Crypto from "node:crypto"
import { convert } from "@dashkite/bake"
import log from "@dashkite/kaiko"

import { Repo, Repos, GitIgnore, Script, FSX } from "./helpers"

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

  root: ".tempo"

  path: ( name ) ->
    Path.join Metarepo.root, name

  git: ({ organization, name }) ->
    "git@github.com:#{ organization }/#{ name }.git"

  add: ( repo ) ->
    { organization, name } = Repo.parse repo
    try
      await Repos.add { organization, name }
      await GitIgnore.add ".tempo"
      await Metarepo.sync()
    catch error
      log.error error
      try
        await Metarepo.remove repo

  remove: ( repo ) ->
    try
      { organization, name } = Repo.parse repo
      Repos.remove { organization, name }
      await FS.rm 
      await FS.rm name, recursive: true
    catch error
      log.error error
  
  clone: ( metarepo ) ->
    { organization, name } = Repo.parse metarepo
    git = Metarepo.git { organization, name }
    await Script.run "git clone #{ git }"
    cwd = process.cwd()
    process.chdir name
    await FS.mkdir Metarepo.root, recursive: true
    await Metarepo.sync()
    process.chdir cwd

  sync: ->
    await Script.run "git pull"
    repos = await Repos.load()
    for { organization, name } in repos
      unless await FSX.isDirectory Metarepo.path name
        git = Metarepo.git { organization, name }
        path = Metarepo.path name
        try
          await Script.run "git clone #{ git } #{ path }", cwd: name
          await run "ln -sf #{ path }"
        catch error
          log.error error
    # do Metarepo.prune

  prune: ->
    for path in await FS.readdir Metarepo.root
      if await FSX.isDirectory path
        name = Path.basename path
        if !( repo = await Repos.get name )?
          if !( await Repo.changed name )
            try
              await FS.rm ( Metarepo.path path ), recursive: true
              await FS.rm path
            catch error
              log.error error
          else
            log.warn "Unable to prune #{ name }
              because it has changes"

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