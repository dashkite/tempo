import {spawn} from "child_process"
import {resolve} from "path"
import {promise, all, w} from "panda-parchment"
import {reduce} from "panda-river"
import log from "./log"

utf8 = (data) -> data.toString "utf8"
trim = (promise) -> (await promise).trim()

exec = (command, pkg, options) ->

  promise (resolve, reject) ->

    [program, args] = w command

    log.info pkg, "run [#{command}]"

    unless options.rehearse

      path = resolve process.cwd(), pkg.path

      child = spawn program, args, cwd: path, exec: true

      cat = (text, buffer) ->
        _text = utf8 buffer
        log.debug pkg, _text
        string += _text

      stdout = trim reduce cat, "", child.stdout
      stderr = trim reduce cat, "", child.stderr

      child.on "error", (error) ->
        log.info pkg, error.message
        reject error
        log.debug pkg, error

      child.on "close", (status) ->
        if status != 0
          log.debug pkg, "[#{command}] exited with a non-zero status"
        resolve {command, status, stdout, stderr}

    else

      resolve
        command: command
        status: 0
        stdout: ""
        stderr: ""

export default exec
