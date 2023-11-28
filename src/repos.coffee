import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import { log } from "./logger"
import Repo from "./repo"
import {
  progress
  benchmark
} from "./helpers"

Repos = 

  run: do ({ run } = {}) ->

    run = generic name: "Repos.run"

    generic run,
      Type.isArray, 
      Type.isString, 
      Type.isObject,  
      ( repos, command, { serial }) ->
        duration = await benchmark "tempo", ->
          if repos.length > 0
            if serial
              for { name } in repos
                await Repo.run name, command        
            else
              await progress count: repos.length, ( bar ) ->
                Promise.all do ->
                  for { name } in repos
                    do ( name ) ->
                      await Repo.run name, command
                      bar.increment()
          else
            log
              .scope command
              .warn "No repos selected"
        log
          .scope command
          .info "finished in",
          "#{ duration }s"

    generic run,
      Type.isArray,
      Type.isString,
      ( groups, command ) ->
        duration = await benchmark "tempo", ->
          count = 0
          for group in groups
            count += group.length
          await progress { count }, ( bar ) ->
            for group in groups
              await Promise.all do ->
                for { name } in group
                  do ( name ) ->
                    await Repo.run name, command
                    bar.increment()
        log
          .scope command
          .info "finished in",
          "#{ duration }s"

    # return the resulting generic
    run

  tag: ( repos, tags ) ->
    for repo in repos
      Repo.tag repo, tags

  untag: ( repos, tags ) ->
    for repo in repos
      Repo.untag repo, tags

export default Repos 