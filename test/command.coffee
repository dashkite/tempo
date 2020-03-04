import assert from "assert"
import util from "util"
import {print, test, success} from "amen"
import {collect, map} from "panda-river"
import {first} from "panda-parchment"
import log from "../src/log"
import {parse} from "../src/parse"
import Package from "../src/package"
import commands from "../src/commands"

run = (pkg, command, options) -> commands[command] pkg, options

scenario = (_command) ->
  [command, options] = parse "rehearse #{_command}"
  pkg = Package.create path: "./test/files", constraints: [ "builder" ]
  run pkg, command, options

do ->

  print await test "command", [

    await test "verify", ->
      [pkg, context] = await scenario "verify"
      assert.deepEqual (collect map first, pkg.actions),
        [ "npm audit --json", "npm outdated --json", "npm ci", "npm test" ]
      assert pkg.updates["LICENSE.md"]?

    # await test "update", ->
    #   [pkg, context] = await scenario "update"
    #   assert.deepEqual pkg.actions,
    #     [ "npm update" ]
    #
    # await test "refresh", ->
    #   [pkg, context] = await scenario "refresh"
    #   assert pkg.updates["LICENSE.md"]?
    #
    # await test "version", ->
    #   [pkg, context] = await scenario "version"
    #   assert.deepEqual pkg.actions,
    #     [ "npm version patch", "git push --tags" ]
    #
    # await test "publish", ->
    #   [pkg, context] = await scenario "publish"
    #   assert.deepEqual pkg.actions,
    #     [ "npm publish --access public" ]
    #
    # await test "packages"



  ]
