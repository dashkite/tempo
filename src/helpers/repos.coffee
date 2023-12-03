import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as It from "@dashkite/joy/iterable"
import { generic } from "@dashkite/joy/generic"
import Zephyr from "@dashkite/zephyr"

has = ( keys ) -> 
  if !( Type.isArray keys )
    keys = [ keys ]
  ( value ) -> keys.every ( key ) -> value[ key ]?

push = ( stack, value ) -> stack.unshift value ; value

remove = ( list, target ) ->
  if ( index = list.indexOf target ) > -1
    list.splice index, 1

Repos =

  load: -> Zephyr.read ".tempo/repos.yaml"

  get: ( name ) ->
    repos = await do Repos.load
    repos.find ( repo ) -> repo.name == name

  find: do ({ find } = {}) ->

    find = generic
      name: "Repos.find"
      default: Repos.load

    generic find,
      ( has "include" ),
      ({ include, options... }) ->
        if Type.isString
          include = await Zephyr.read exclude
        Fn.flow [
          -> Repos.find options
          It.select ( repo ) -> repo.name in include )
        ]          

    generic find,
      ( has "repos" ),
      ({ repos, include }) ->
        result = await Repos.find include: repos
        if include?
          result = result.concat await Repos.find { include }
        result

    generic find,
      ( has "tag" ),
      ({ tag, options... }) ->
        Fn.flow [
          -> Repos.find options
          It.filter ( repo ) -> 
            repo.tags? && ( tag in repo.tags )
        ]

    generic find,
      ( has "exclude" ),
      ({ exclude, options... }) ->
        if Type.isString
          exclude = await Zephyr.read exclude          
        Fn.flow [
          -> Repos.find options
          It.filter ( repo ) -> 
            !( repo.name in exclude )
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
          groups = memos[ key ]

        # default the trivial group
        groups ?= [( state.repos.map ({ name }) -> name )]
        
        # check for missing repos
        # add to first group if we find any
        for repo in repos
          found = ( groups.find ( group ) -> repo.name in group )?
          unless found
            push groups[ 0 ], repo.name
        
        # remove repos that are not in the target repos list
        groups = do ->
          for group in groups
            removals = []
            for name in group
              found = ( repos.find ( repo ) -> repo.name = name )?
              unless found
                push removals, name
            group.filter ( name ) -> !( name in removals )

        index = 0
        built = 0
        before = -1
        retries = if retry then 6 else 0
        failures = {}
        for name in repos
          failures[ name ] = 0

        while ( group = groups[ index ])? && ( built != before )
          before = built
          failed = []
          for subgroup from batches group, batch
            log.debug { subgroup }
            await Promise.all do ->
              for repo in subgroup
                do ( repo ) ->
                  log.debug { repo }
                  if failures[ repo ] <= retries
                    try
                      await Script.sh command, cwd: repo
                      yield repo
                    catch
                      log.debug failed: repo
                      push failed, repo
                  else
                    log.warn "Too many failures running [ #{ command } ]
                      for repo [ #{ repo } ]"

          # demote failures
          if failed.length > 0
            log.debug { failures }
            groups[ index + 1 ] ?= []
            for repo in failed
              log.debug demoting: repo
              failures[ repo ]++
              remove group, repo
              push groups[ index + 1 ], repo
          index++

        Zephyr.update ".tempo/memos.json", ( memos ) ->
          memos[ key ] = groups

    generic run, 
      ( has "serial" ),
      ({ serial, options... }) ->
        Repos.run { batch: 1, options... }

    generic run, 
      ( has [ "args", "command" ]),
      ({ command, args, options... }) ->
        if Type.isObject command
          { command, _options... } = command
          options = { options..., _options... }
        Repos.run {
          command: Script.expand command, args
          options...
        }

    generic run, 
      ( has "script" ),
      ({ script, options... }) ->
        Repos.run {
          command: await Script.find script
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
