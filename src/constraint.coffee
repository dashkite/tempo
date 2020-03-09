import {resolve} from "path"
import {assign} from "panda-parchment"
import constraints from "./constraints"

# TODO add file cache
# TODO add read helper

class Constraint

  @create: (options) -> new Constraint options

  @path: resolve __dirname, "..", "constraints"

  @resolve: ({name}, path) -> resolve @path, name, path

  # this is just here for completeness
  @run: (constraint, pkg, options) ->
    constraint.f constraint, pkg, options

  constructor: (@name) ->
    assign @,
      f: constraints[@name]
      updates: {}
      cache:
        content: {}
        data: {}

  resolve: (path) -> Constraint.resolve @, path

  run: (pkg, options) -> Constraint.run @, pkg, options

export default Constraint
