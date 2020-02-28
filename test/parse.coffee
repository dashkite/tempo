import assert from "assert"
import {print, test, success} from "amen"

import {parse} from "../src/parse"

pass = (input, expected) ->
  test input, ->
    [command, options] = parse input
    assert.equal command, expected.command
    assert.deepEqual options, expected.options

fail = (input) ->
  test input, -> assert.equal undefined, parse input

do ->

  print await test "parse", [

    pass "publish", command: "publish"

    pass "packages list",
      command: "packages",
      options: subcommand: "list"

    pass "verify", command: "verify"

    pass "verify build",
      command: "verify"
      options: scope: "build"

    pass "update", command: "update"

    pass "update wild",
      command: "update"
      options: wild: true

    pass "refresh", command: "refresh"

    pass "bump", command: "bump"

    pass "bump major",
      command: "bump"
      options: major: true

    fail "notacommand"
    fail "update notanoption"

    pass "rehearse verify",
      command: "verify",
      options: rehearse: true

  ]
