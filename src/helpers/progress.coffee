import * as TK from "terminal-kit"

Progress = 
  make: ({ count }) ->
    bar = TK.terminal.progressBar
      title: "Progress"
      percent: true
      eta: true
      barChar: "◼︎"
      barHeadChar: "◼︎"
    counter = 0
    TK.terminal "\n"

    increment: -> bar.update ++counter / count
    set: ( counter ) -> bar.update counter / count

export { Progress }
export default Progress