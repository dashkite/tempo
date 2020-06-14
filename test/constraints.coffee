import assert from "assert"
import {print, test, success} from "amen"

# import {resolve} from "path"

import {file, property} from "../src/exemplars/combinators"

# do ->
#
#   context = ->
#     refresh: false
#     project:
#       path: resolve "."
#       cached: {}
#       updates: {}
#     exemplar:
#       path: resolve "test", "files"
#       cached: {}
#     messages:
#       info: []
#       warn: []
#       fatal: []
#
#   print await test "exemplars", [
#
#     test "property", [
#
#       test "update", ->
#         assert.equal true,
#           ((await property "package.json", "name", "tempo", context())
#           ?.project?.updates?["package.json"]?)
#
#       test "with a compound reference", ->
#         # should not update b/c value is already correct
#         assert.equal 0,
#           ((await property "package.json",
#             "scripts.test", "p9k test", context())
#           ?.messages?.info?.length)
#
#       test "invalid reference", ->
#         assert.equal 1,
#           ((await property "package.json",
#             "scripts.fubar", "p9k test", context())
#           ?.messages?.warn?.length)
#
#     ]
#
#     test "file", [
#
#       test "no update", ->
#         assert.equal false, ((await file "README.md", context())
#           ?.project?.updates?["README.md"]?)
#
#       test "update", ->
#         assert.equal true, ((await file "LICENSE.md", context())
#           ?.project?.updates?["LICENSE.md"]?)
#
#       test "missing file", ->
#         assert 1, (await file "missing-file", context())
#           ?.messages?.warn?.length
#
#     ]
#
#   ]
