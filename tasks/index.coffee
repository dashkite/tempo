import "coffeescript/register"
import FS from "fs/promises"

import * as t from "@dashkite/genie"
import preset from "@dashkite/genie-presets"

import * as _ from "@dashkite/joy"
import * as m from "@dashkite/masonry"
import {coffee} from "@dashkite/masonry/coffee"

preset t

# TODO incorporate into preset
t.define "bin", ->
  await FS.mkdir "build/node/src/bin", recursive: true
  FS.copyFile "src/bin/tempo", "build/node/src/bin/tempo"

t.after "build", "bin"