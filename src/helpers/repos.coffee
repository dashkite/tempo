import Path from "node:path"
import * as Fn from "@dashkite/joy/function"
import * as It from "@dashkite/joy/iterable"
import * as Type from "@dashkite/joy/type"
import * as Text from "@dashkite/joy/text"
import { generic } from "@dashkite/joy/generic"
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

Memos =

  path: Path.join ".tempo", "memos.json"

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
      ({ repos, command, key, batch, retry }) ->

        batch ?= 6 # max parallel builds
        retry ?= true

        if retry
          memos = await Zephyr.read Memos.path
          memos ?= {}
          groups = memos[ key ]

        # default the trivial group
        groups ?= [( repos.map ({ name }) -> name )]

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

        index = 0
        succeeded = 0
        before = -1
        retries = if retry then 6 else 0

        # initialize failures lookup
        failures = {}
        ( failures[ repo.name ] = 0 ) for repo in repos  

        log.info 
          console: true
          message: "Running [ #{ Text.elide 40, "...", command } ]"
          command: command

        progress = Progress.make count: repos.length
        do progress.start

        limiter = pLimit batch

        while ( group = groups[ index ])? && ( succeeded != before )
          before = succeeded
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
                      succeeded++
                      do progress.increment
                    catch error
                      log.error
                        console: true
                        repo: repo
                        message: error.message
                        error: error
                      push failed, repo if retry
                  else
                    log.error
                      console: true
                      repo: repo 
                      failures: failures[ repo ]
                      retries: retries
                      message: "Too many failures"

          await Promise.all pending

          # demote failures
          if succeeded != before && failed.length > 0
            groups[ index + 1 ] ?= []
            for repo in failed
              log.debug {
                message: "demoting repo"
                repo
              }
              failures[ repo ]++
              remove group, repo
              push groups[ index + 1 ], repo

          index++

        do progress.stop

        log.info 
          console: true
          message: "succeeded: #{ succeeded },
            failed: #{ repos.length - succeeded }"

        memos[ key ] = groups
        Zephyr.write ".tempo/memos.json", memos

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