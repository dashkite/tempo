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

    pass "tempo publish", command: "publish"

    pass "tempo packages list",
      command: "packages",
      options: subcommand: "list"

    pass "tempo verify", command: "verify"

    pass "tempo verify build",
      command: "verify"
      options: scope: "build"

    pass "tempo update", command: "update"

    pass "tempo update wild",
      command: "update"
      options: wild: true

    pass "tempo refresh", command: "refresh"

    pass "tempo bump", command: "bump"

    pass "tempo bump major",
      command: "bump"
      options: major: true

    fail "tempo notacommand"
    fail "tempo update notanoption"

    pass "tempo rehearse verify",
      command: "verify",
      options: rehearse: true

  ]
