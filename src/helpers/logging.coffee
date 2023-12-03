import * as log from "@dashkite/kaiko"
import * as TK from "terminal-kit"

colors =
  info: "green"
  warn: "yellow"
  error: "red"
  fatal: "brightRed"
  debug: "blue"

log.observe ({ level, data }) ->
  color = colors[ level ] ? "white"
  TK.terminal[ color ] "[ tempo ][ #{ data } ]"