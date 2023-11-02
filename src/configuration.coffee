import FS from "node:fs/promises"
import YAML from "js-yaml"

import { negate } from "@dashkite/joy/predicate"

matches = ( repo ) ->
  ({ organization, name }) ->
    ( organization == repo.organization ) && ( name == repo.name )

doesNotMatch = ( repo ) -> negate matches repo

read = ( path ) ->
  try
    YAML.load await FS.readFile path, "utf8"

write = ( path, data ) ->
  FS.writeFile "tempo.yaml", YAML.dump data

Configuration =

  load: do ({ configuration } = {}) -> ->
    configuration ?= await do ->
      repos: await read ".repos.yaml"
      scripts: await read ".scripts.yaml"
  
  save: ({ repos, scripts }) ->
    Promise.all [
      write ".repos.yaml", repos
      write ".scripts.yaml", scripts
    ]

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

    load: ( path ) ->
      configuration = await Configuration.load()
      ( YAML.load await FS.readFile path, "utf8" )
        .map ( name ) ->
          configuration.repos.find ( repo ) -> repo.name == name
        .filter ( repo ) -> repo?

    list: ({ include, exclude } = {}) ->
      configuration = await Configuration.load()
      include = if include?
        await Configuration.Repos.load include
      else configuration.repos
      exclude = if exclude?
        await Configuration.Repos.load exclude 
      else []
      include.filter ( repo ) -> !( repo in exclude )

    groups: ( path ) ->
      configuration = await Configuration.load()
      ( YAML.load await FS.readFile path, "utf8" )
        .map ( group ) ->
          group
            .map ( name ) ->
              configuration.repos.find ( repo ) -> repo.name == name
            .filter ( repo ) -> repo?






export default Configuration