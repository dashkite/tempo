import { log } from "./logger"
import Repo from "./repo"
import {
  progress
  benchmark
} from "./helpers"

Repos = 

  run: ( repos, command, { serial }) ->
    duration = await benchmark "tempo", ->
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

    log
      .scope command
      .info "finished in",
      "#{ duration }s"

  runGroups: ( groups, command ) ->
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

export default Repos 