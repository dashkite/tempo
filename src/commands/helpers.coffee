import {spawn} from "child_process"
import {resolve} from "path"
import {createWriteStream} from "fs"
import {w, promise, isType, isFunction} from "panda-parchment"
import {curry} from "panda-garden"
import Method from "panda-generics"

shell = (command, path = ".") ->
  [program, args...] = w command
  spawn program, args, cwd: resolve process.cwd(), path

pipe = Method.create "pipe"

isStream = (value) -> isFunction value.pipe
isChildProcess = (value) -> value.constructor.name == "ChildProcess"
isProcess = isType process.constructor

Method.define pipe, isStream, isStream, isChildProcess,
  (out, err, child) ->
    promise (resolve, reject) ->
      child.stdout.pipe out
      child.stderr.pipe err
      child.on "error", (error) -> reject error
      child.on "close", (status) ->
        if status == 0
          resolve()
        else
          reject new Error "child process exited with non-zero status: #{status}"

Method.define pipe, isStream, isChildProcess, (stream, child) ->
  pipe stream, stream, child

Method.define pipe, isProcess, isChildProcess, (stream, child) ->
  pipe process.stdout, process.stderr, child

print = (child) -> pipe process, child

log = curry (path, child) -> pipe (createWriteStream resolve path), child

export {shell, pipe, print, log}
