import {spawn} from "child_process"
import {resolve} from "path"
import {createWriteStream} from "fs"
import {w, promise, isType, isFunction} from "panda-parchment"
import {curry} from "panda-garden"

shell = (command, path = ".") ->
  [program, args...] = w command
  spawn program, args, cwd: resolve process.cwd(), path

pipe = (child, logger) ->
  promise (resolve, reject) ->
    child.stdout.on "data", (data) -> logger.info data
    child.stderr.on "data", (data) -> logger.error data
    child.on "error", (error) -> reject error
    child.on "close", (status) ->
      if status == 0
        resolve()
      else
        reject new Error "child process exited with non-zero status: #{status}"

export {shell, pipe}
