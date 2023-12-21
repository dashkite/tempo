import FS from "node:fs/promises"
import * as Genie from "@dashkite/genie"

# TODO incorporate into preset
Genie.define "bin", ->
  await FS.mkdir "build/node/src/bin", recursive: true
  FS.copyFile "src/bin/tempo", "build/node/src/bin/tempo"

Genie.after "build", "bin"