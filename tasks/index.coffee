import "coffeescript/register"
import FS from "fs/promises"

import * as t from "@dashkite/genie"
import preset from "@dashkite/genie-presets"

preset t

# TODO incorporate into preset
t.define "bin", ->
  await FS.mkdir "build/node/src/bin", recursive: true
  FS.copyFile "src/bin/tempo", "build/node/src/bin/tempo"

t.after "build", "bin"