import {shell, print} from "./helpers"

export default ({scope}) ->
  console.log "Running verify for #{scope ? 'all'}"
  print shell "npm audit"
