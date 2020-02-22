import {shell, log} from "./helpers"

export default ({scope}) ->
  console.log "Tempo: running verify for #{scope ? 'all'}"
  logger = log "./tempo.log"
  logger shell "npm audit"
