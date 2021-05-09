import YAML from "js-yaml"
import FS from "fs/promises"

do ->

  [ path ] = process.argv[2..]

  description = YAML.load await FS.readFile path, "utf8"

  console.log description
