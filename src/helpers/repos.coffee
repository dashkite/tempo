import Path from "node:path"
import Crypto from "node:crypto"
import * as Fn from "@dashkite/joy/function"
import * as Arr from "@dashkite/joy/array"
import * as It from "@dashkite/joy/iterable"
import * as Type from "@dashkite/joy/type"
import * as Text from "@dashkite/joy/text"
import { generic } from "@dashkite/joy/generic"
import { convert } from "@dashkite/bake"
import Zephyr from "@dashkite/zephyr"
import log from "@dashkite/kaiko"
import pLimit from "p-limit"
import Progress from "./progress"
import { Scripts, Script } from "./scripts"

has = ( keys ) -> 
  if !( Type.isArray keys )
    keys = [ keys ]
  ( value ) -> keys.every ( key ) -> value[ key ]?

push = ( stack, value ) -> stack.unshift value ; value

remove = ( list, target ) ->
  if ( index = list.indexOf target ) > -1
    list.splice index, 1

slice = ( stack, start, skip ) ->
  stack.slice start, start + skip

partition = ( size, list ) ->
  i = 0
  j = Math.ceil list.length / size
  while i < j
    yield slice list, ( i++ * size ), size


Hash =

  md5: ( buffer ) ->
    convert from: "bytes", to: "base36",
      new Uint8Array do ->
        Crypto
          .createHash "md5"
          .update buffer
          .digest()
          .buffer

  array: ( array ) ->
    Text.truncate 8, 
      Hash.md5 array.sort().join ","

Repos =
  
  path: Path.join ".tempo", "repos.yaml"

  initialize: ->
    Zephyr.update Repos.path, ( repos ) -> repos ?= []

  load: -> Zephyr.read Repos.path

  get: ( name ) ->
    repos = await do Repos.load
    repos.find ( repo ) -> repo.name == name

  add: ({ organization, name }) ->
    Zephyr.update Repos.path, ( repos ) ->
      repos.push { organization, name }
      repos

  remove: ({ organization, name }) ->
    Zephyr.update Repos.path, ( repos ) ->
      repo = repos.find ( repo ) ->
        repo.organization == organization &&
          repo.name == name
      remove repos, repo
      repos

  tag: ( repos, tags ) ->
    for repo in repos
      await Repo.tag repo, tags

  untag: ( repos, tags ) ->
    for repo in repos
      await Repo.untag repo, tags

  find: do ({ find } = {}) ->

    find = generic
      name: "Repos.find"
      default: -> do Repos.load

    generic find,
      ( has "repos" ),
      ({ repos, options... }) -> 
        do Fn.flow [
          -> Repos.find options
          It.select ( repo ) -> repo.name in repos
        ]
        
    generic find,
      ( has "include" ),
      ({ include, options... }) ->
        repos = await Zephyr.read include
        Repos.find { repos, options... }

    generic find,
      ( has [ "repos", "include" ] ),
      ({ repos, include }) ->
        do Fn.flow [
          Repos.find include: repos
          ( result ) -> 
            result.concat await Repos.find { include }
        ]

    generic find,
      ( has "tags" ),
      ({ tags, options... }) ->
        do Fn.flow [
          -> Repos.find options
          It.select ( repo ) -> 
            repo.tags? && ( tags.some ( tag ) -> tag in repo.tags )
        ]

    generic find,
      ( has "exclude" ),
      ({ exclude, options... }) ->
        exclude = await Zephyr.read exclude
        do Fn.flow [
          -> Repos.find options
          It.select ( repo ) -> !( repo.name in exclude )
        ]

    find

  run: do ({ run } = {}) ->
  
    run = generic name: "Repos.run"

    generic run, Type.isObject,
      ({ repos, command, key, retries, memo, batch }) ->

        if memo?
          memos = await Zephyr.read memo
          memos ?= {}
          groups = memos[ key ]

        # default the trivial group
        groups ?= [ Arr.shuffle ( repos.map ({ name }) -> name ) ]

        # check for missing repos
        # add to first group if we find any
        for repo in repos
          found = ( groups.find ( group ) -> repo.name in group )?
          unless found
            push groups[ 0 ], repo.name
        
        groups = groups
          # remove repos that are not in the target repos list
          .map ( group ) ->
            group.filter ( name ) ->
              ( repos.find ( repo ) -> repo.name == name )?
          # remove empty groups since they will halt the run loop
          .filter ( group ) -> group.length != 0

        failed = undefined
        hash = undefined
        history = []
        # initialize failures lookup
        failures = {}
        ( failures[ repo.name ] = 0 ) for repo in repos  

        log.info 
          console: true
          message: "Running [ #{ Text.elide 40, "...", command } ]"
          command: command

        limiter = pLimit batch

        done = ->
          failed? &&
            (( failed.length == 0 ) ||
              (( hash = Hash.array failed ) in history ))

        count = 0
        while !done()

          if count > 0
            groups = [ Arr.shuffle ( repos.map ({ name }) -> name ) ]


          ( history.push hash ) if hash?
          ( groups.push failed ) if failed?

          index = 0
          succeeded = new Set

          progress.stop() if progress?
          console.log "Attempt ##{ ++count }"
          progress = Progress.make count: repos.length
          progress.start()

          mulligan = true
          while ( group = groups[ index ])?
            before = succeeded.size
            failed = []

            pending = 
              for repo in group
                do ( repo ) ->
                  limiter ->
                    log.debug { repo, command }
                    if failures[ repo ] <= retries
                      try
                        result = await Script.run command, cwd: repo
                        log.debug { repo, result }
                        succeeded.add repo
                        console.log { repo, succeeded: succeeded.size }
                        progress.set succeeded.size
                      catch error
                        log.error
                          repo: repo
                          message: error.message
                          error: error
                        push failed, repo
                    else
                      log.error
                        repo: repo 
                        failures: failures[ repo ]
                        retries: retries
                        message: "Too many failures"

            await Promise.all pending

            if ( failed.length > 0 )
              
              if mulligan
                mulligan = false
              else
                mulligan = true
                if ( succeeded.size > before )
                  groups[ ++index ] ?= []
                else
                  ++index

                if groups[ index ]?
                  for repo in failed
                    log.debug {
                      message: "demoting repo"
                      repo
                    }
                    failures[ repo ]++
                    remove group, repo
                    push groups[ index ], repo

            else

              mulligan = true
              ++index

        progress.stop()

        for repo in repos when !( succeeded.has repo.name )
          log.error
            console:true
            repo: repo
            message: "failed"

        log.info 
          console: true
          message: "succeeded: #{ succeeded.size },
            failed: #{ repos.length - succeeded.size }"

    generic run, 
      ( has "serial" ),
      ({ serial, options... }) ->
        Repos.run { batch: 1, options... }

    generic run, 
      ( has [ "command", "args"  ]),
      ({ command, args, options... }) ->
        if Type.isObject command
          { command } = command
          options = { options..., command.options... }
        Repos.run {
          command: Script.expand command, args
          options...
        }

    generic run, 
      ( has "script" ),
      ({ script, options... }) ->
        Repos.run {
          command: await Scripts.find script
          options...
        }

    run

Repo =

  parse: ( specifier ) ->
    [ organization, name ] = specifier.split "/"
    { organization, name }

  same: ( a, b ) ->
    a.organization == b.organization && a.name == b.name

  save: ( repo ) ->
    Zephyr.update Repos.path, ( repos ) ->
      for _repo in repos      
        if Repo.same _repo, repo
          repo
        else
          _repo

  tag: ( repo, tags ) ->
    repo.tags ?= []
    repo.tags = Array.from new Set [ repo.tags..., tags... ]
    Repo.save repo

  untag: ( repo, tags ) ->
    repo.tags = do ->
      tag for tag in repo.tags when !( tag in tags )
    Repo.save repo

  changed: ( name ) ->
    try
      # returns non-zero status if there are changes in the repo
      await Script.run "git diff-index --quiet HEAD", cwd: name
      false
    catch
      true

export { Repos, Repo }