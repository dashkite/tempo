import {spawn} from "child_process"
import {resolve} from "path"
import {w, promise} from "panda-parchment"

shell = (command, path = ".") ->
  [program, args...] = w command
  spawn program, args, cwd: resolve process.cwd(), path

fail = (status) ->
  new Error "child process exited with non-zero status: #{status}"

print = (child) ->
  promise (resolve, reject) ->
    child.stdout.pipe process.stdout
    child.stderr.pipe process.stderr
    child.on "error", (error) -> reject error
    child.on "close", (status) ->
      if status == 0 then resolve() else reject fail status

export {shell, print}
