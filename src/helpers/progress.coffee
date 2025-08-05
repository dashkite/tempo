import * as TK from "terminal-kit"

pct = ( n, m ) ->
  ((Math.floor ( n / m ) * 100) / 100)

Progress = 
  enabled: false
  make: ({ title, count }) ->
    if Progress.enabled
      bar = TK.terminal.progressBar
        title: title ? "Progress"
        percent: true
        eta: true
        barChar: "◼︎"
        barHeadChar: "◼︎"
        syncMode: true
      counter = 0

      start: -> bar.update 0
      increment: -> bar.update pct ++counter, count
      stop: -> 
        bar.stop()
        TK.terminal "\n"
    else
      start: ->
      increment: ->
      stop: ->

export { Progress }
export default Progress