import assert from "assert"
import {parse} from "../src/parse"
import colors from "colors/safe"

import commands from "../src/commands"


[command, options] = parse "tempo verify constraints"
commands[command] options
