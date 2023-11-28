import { log } from "./logger"
import { run } from "./helpers"

Repo = 

  run: ( name, command ) ->
    log
      .scope name
      .info command
    try
      await run command, cwd: name
    catch error
      log
        .scope name
        .error error.message
  
  parse: ( repo ) ->
    [ organization, name ] = repo.split "/"
    { organization, name }

  tag: ( repo, tags ) ->
    repo.tags ?= []
    repo.tags = Array.from new Set [ repo.tags..., tags... ]

  untag: ( repo, tags ) ->
    if repo.tags?
      repo.tags = repo.tags.filter ( tag ) -> !( tag in tags )

export default Repo