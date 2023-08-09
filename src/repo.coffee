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

export default Repo