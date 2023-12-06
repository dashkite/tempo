import * as Fn from "@dashkite/joy/function"
import * as It from "@dashkite/joy/iterable"
import * as Type from "@dashkite/joy/type"
import * as Text from "@dashkite/joy/text"
import { generic } from "@dashkite/joy/generic"
import Zephyr from "@dashkite/zephyr"
import { Scripts, Script } from "./scripts"
import log from "@dashkite/kaiko"

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

Repos =

  load: -> Zephyr.read ".tempo/repos.yaml"

  get: ( name ) ->
    repos = await do Repos.load
    repos.find ( repo ) -> repo.name == name

  find: do ({ find } = {}) ->

    find = generic
      name: "Repos.find"
      default: -> do Repos.load

    generic find,
      ( has "include" ),
      ({ include, options... }) ->
        if Type.isString
          include = await Zephyr.read include
        do Fn.flow [
          -> Repos.find options
          It.select ( repo ) -> repo.name in include
        ]

    generic find,
      ( has [ "repos", "include" ] ),
      ({ repos, include }) ->
        result = await Repos.find include: repos
        if include?
          result = result.concat await Repos.find { include }
        result

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
        if Type.isString
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
          memos = await Zephyr.read ".tempo/memos.json"
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
          force: true
          message: "Running [ #{ Text.elide 30, "...", command } ]"
          command: command

        while ( group = groups[ index ])? && ( succeeded != before )
          before = succeeded
          failed = []
          for subgroup from partition batch, group
            promised = do ->
              for repo in subgroup
                do ( repo ) ->
                  log.debug { repo }
                  if failures[ repo ] <= retries
                    try
                      result = await Script.run command, cwd: repo
                      log.debug { repo: repo, result }
                      before = succeeded
                      succeeded++
                      true
                    catch error
                      log.error
                        repo: repo
                        message: error.message
                        error: error
                      push failed, repo if retry
                      false
                  else
                    log.warn
                      repo: repo 
                      failures: failures[ repo ]
                      retries: retries
                      message: "Too many failures"
                    false

            for promise in promised
              yield await promise

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

  changed: ( name ) ->
    try
      # returns non-zero status if there are changes in the repo
      await Script.run "git diff-index --quiet HEAD", cwd: name
      false
    catch
      true


export { Repos, Repo }