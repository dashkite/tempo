import assert from "assert"
import {parse} from "../src/parse"

pass = (input, expected) ->
  [command, options] = parse input
  assert.equal command, expected.command
  assert.deepEqual options, expected.options

fail = (input) ->
  assert.equal undefined, parse input

pass "tempo publish", command: "publish"
pass "tempo packages list",
  command: "packages",
  options: subcommand: "list"

pass "tempo verify",
  command: "verify"
pass "tempo verify build",
  command: "verify"
  options: scope: "build"
pass "tempo update",
  command: "update"
pass "tempo update wild",
  command: "update"
  options: wild: true
pass "tempo refresh",
  command: "refresh"
pass "tempo bump",
  command: "bump"
pass "tempo bump major",
  command: "bump"
  options: major: true
fail "tempo notacommand"
