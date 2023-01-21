import FS from "node:fs/promises"
import YAML from "js-yaml"

import { negate } from "@dashkite/joy/predicate"

matches = ( repo ) ->
  ({ organization, name }) ->
    ( organization == repo.organization ) && ( name == repo.name )

doesNotMatch = ( repo ) -> negate matches repo

Configuration =

  load: ->
    try
      YAML.load await FS.readFile "tempo.yaml", "utf8"
    catch
      repos: []
  
  save: (configuration) ->
    FS.writeFile "tempo.yaml", YAML.dump configuration

  Repos:

    add: ( repo ) ->
      configuration = await Configuration.load()
      unless configuration.repos.find matches repo
        configuration.repos.push repo
        Configuration.save configuration

    remove: ( repo ) ->
      configuration = await Configuration.load()
      configuration.repos = configuration.repos.filter doesNotMatch repo
      Configuration.save configuration

    list: ( targets ) ->
      configuration = await Configuration.load()
      if targets?
        ( YAML.load await FS.readFile targets, "utf8" )
          .map ( name ) ->
            configuration.repos.find ( repo ) -> repo.name == name
      else
        configuration.repos

export default Configuration