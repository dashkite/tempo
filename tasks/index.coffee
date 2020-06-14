p9k = require "panda-9000"

import {join, resolve, relative} from "path"
import {spawn} from "child_process"
import {w} from "panda-parchment"
import {rmr} from "panda-quill"
import {go, map, wait, tee} from "panda-river"
import coffee from "coffeescript"

# TODO we really need a solid shell abstraction for quill
shell = (command, path = ".") ->
  child = spawn command,
    shell: true
    cwd: resolve process.cwd(), path
    stdio: "inherit"

local = (path) ->
  require.resolve path, paths: [ process.cwd() ]

compile = tee ({source, target}) ->
  target.content = coffee.compile source.content,
    bare: true
    inlineMap: true
    filename: join "..", relative ".", source.path
    transpile:
      presets: [[
        local "@babel/preset-env"
        targets: node: "current"
      ]]

{define, glob, read, write, extension, copy} = p9k

define "build", [ "clean", "bin&", "exemplars&", "js&"]

define "clean", -> rmr "build"

define "js", ->
  go [
    glob [ "**/*.coffee" ], "./src"
    wait map read
    compile
    map extension ".js"
    map write "./build/src"
  ]

define "bin", ->
  go [
    glob [ "**/*" ], "./src/bin"
    map copy "./build/src/bin"
  ]

define "exemplars", ->
  go [
    glob [ "**/*" ], "./exemplars"
    map copy "./build/exemplars"
  ]

define "test:js", ->
  go [
    glob [ "**/*.coffee" ], "./test"
    wait map read
    compile
    map extension ".js"
    map write "./build/test"
  ]

define "test:run", ->
  shell "node build/test/index.js"

define "test", [ "build", "test:js", "test:run" ]
