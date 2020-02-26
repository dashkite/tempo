import assert from "assert"
import {resolve} from "path"
import {read} from "panda-quill"
import colors from "colors/safe"

import {file, property} from "../src/constraints/combinators"

log =
  indent: ""
  title: (description) -> console.log colors.blue log.indent, description
  info: (description) -> console.log colors.green log.indent, description
  warn: (description) -> console.log colors.red log.indent, description

test = (description, f) ->
  try
    await f()
    log.info description
  catch error
    log.warn description

title = (description) ->
  log.title description
  log.indent += "  "

end = -> log.indent = log.indent[0...-2]

do ->

  title "Constraints"

  context =
    refresh: false
    project:
      path: resolve "."
    constraint:
      path: resolve "test", "files"
    updates: {}
    data: {}
    messages:
      info: []
      warn: []
      fatal: []

  title "Property"

  await test "update", ->
    assert.equal true, ((await property "package.json", "name", "tempo", context)
      ?.updates?["package.json"]?)

  await test "with a compound reference", ->
    assert.equal 1,
      ((await property "package.json", "scripts.test", "p9k test", context)
      ?.messages?.info?.length)

  await test "invalid reference", ->
    assert.equal 1,
      ((await property "package.json", "scripts.fubar", "p9k test", context)
      ?.messages?.warn?.length)

  end()

  title "File"

  await test "no update", ->
    assert.equal false, ((await file "README.md", context)
      ?.updates?["README.md"]?)

  await test "update", ->
    assert.equal true, ((await file "LICENSE.md", context)
      ?.updates?["LICENSE.md"]?)

  test "missing file", ->
    assert 2, (await file "missing-file", context)
      ?.messages?.warn?.length
