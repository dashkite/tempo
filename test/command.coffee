import assert from "assert"
import util from "util"
import {print, test, success} from "amen"
import colors from "colors/safe"

import {parse} from "../src/parse"
import {Context, Package} from "../src/helpers"
import commands from "../src/commands"

logger =
  info: (message, args...) ->
    console.info colors.green util.format message, args...

run = (pkg, context) -> commands[context.command] pkg, context

scenario = (_command) ->
  [command, options] = parse "rehearse #{_command}"
  pkg = Package.create path: "./test/files", constraints: [ "builder" ]
  context = Context.create {command, options, logger}
  run pkg, context

do ->

  print await test "command", [

    await test "verify", ->
      [pkg, context] = await scenario "verify"
      assert.deepEqual pkg.actions,
        [ "npm audit", "npm outdated", "npm ci", "npm test" ]
      assert pkg.updates["LICENSE.md"]?

    await test "update", ->
      [pkg, context] = await scenario "update"
      assert.deepEqual pkg.actions,
        [ "npm update" ]

    await test "refresh", ->
      [pkg, context] = await scenario "refresh"
      assert pkg.updates["LICENSE.md"]?

    await test "version", ->
      [pkg, context] = await scenario "version"
      assert.deepEqual pkg.actions,
        [ "npm version patch", "git push --tags" ]

    await test "publish", ->
      [pkg, context] = await scenario "publish"
      assert.deepEqual pkg.actions,
        [ "npm publish --access public" ]

    await test "packages"



  ]
