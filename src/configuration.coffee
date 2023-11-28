import FS from "node:fs/promises"
import YAML from "js-yaml"

import { negate } from "@dashkite/joy/predicate"

matches = ( repo ) ->
  ({ organization, name }) ->
    ( organization == repo.organization ) && ( name == repo.name )

doesNotMatch = ( repo ) -> negate matches repo

fromName = ( repos ) ->
  ( name ) -> repos.find ( repo ) -> repo.name == name

read = ( path ) ->
  try
    YAML.load await FS.readFile path, "utf8"

write = ( path, data ) ->
  FS.writeFile path, YAML.dump data

Configuration =

  load: do ({ configuration } = {}) -> ->
     configuration ?= await do ({ repos, scripts } = {}) ->
      [ repos, scripts ] = await Promise.all [
        Configuration.Repos.load()
        Configuration.Scripts.load()
      ]
      { repos, scripts }
  
  save: ({ repos, scripts }) ->
    Promise.all [
      Configuration.Repos.save repos
      Configuration.Scripts.save scripts
    ]
  
  Scripts:

    load: do ({ scripts } = {}) -> -> scripts ?= read ".scripts.yaml"
    
    save: ( repos ) -> write ".scripts.yaml", repos


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

    load: do ({ repos } = {}) -> -> repos ?= read ".repos.yaml"
    
    save: ( repos ) -> write ".repos.yaml", repos

    update: ( repos ) ->
      _repos = await Configuration.Repos.load()
      for _repo in _repos
        if ( repo = repos.find matches _repo )?
          Object.assign _repo, repo
      Configuration.Repos.save _repos

    find: ( name ) ->
      repos = await Configuration.Repos.load()
      repos.find ( repo ) -> repo.name == name

    list: ({ include, exclude, tags } = {}) ->
      repos = await Configuration.Repos.load()
      if include?
        include = await read include
        repos = repos.filter ( repo ) -> repo.name in include
      if exclude?
        exclude = await read exclude
        repos = repos.filter ( repo ) -> !( repo.name in exclude )
      if tags?
        tags = tags.split "+"
        repos = repos.filter ( repo ) ->
          if repo.tags?
            tags.every ( tag ) -> tag in repo.tags
          else false
      repos

    groups: ( path ) ->
      repos = await Configuration.Repos.load()
      ( await read path )
        .map ( group ) ->
          group
            .map fromName repos
            .filter ( repo ) -> repo?

export default Configuration