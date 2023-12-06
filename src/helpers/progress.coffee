import * as TK from "terminal-kit"

Progress = 
  make: ({ count }) ->
    bar = TK.terminal.progressBar
      title: "Progress"
      percent: true
      eta: true
      barChar: "◼︎"
      barHeadChar: "◼︎"
      syncMode: true
    counter = 0

    
    start: -> bar.update 0
    increment: -> bar.update ++counter / count
    stop: -> 
      bar.stop()
      TK.terminal "\n"

export { Progress }
export default Progress