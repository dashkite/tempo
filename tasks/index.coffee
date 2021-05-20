import "coffeescript/register"
import FS from "fs/promises"

import * as t from "@dashkite/genie"
import preset from "@dashkite/genie-presets"

import * as _ from "@dashkite/joy"
import * as m from "@dashkite/masonry"
import {coffee} from "@dashkite/masonry/coffee"

preset t, "release"

# TODO incorporate into preset
t.define "bin", ->
  await FS.mkdir "build/src/bin", recursive: true
  FS.copyFile "src/bin/tempo", "build/src/bin/tempo"

t.define "clean", m.rm "build"

t.define "build", [ "clean", "bin" ], m.start [
  m.glob [ "{src,test}/**/*.coffee" ], "."
  m.read
  _.flow [
    m.tr coffee target: "node"
    m.extension ".js"
    m.write "build"
  ]
]

t.define "test", "build", m.exec "node", [
  "build/test/index.js"
  "--enable-source-maps"
]
