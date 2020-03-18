import {resolve} from "path"
import {assign} from "panda-parchment"
import {read} from "panda-quill"
import constraints from "./constraints"

# TODO add file cache
# TODO add read helper

class Constraint

  @create: (options) -> new Constraint options

  @path: resolve __dirname, "..", "constraints"

  @resolve: ({name}, path) -> resolve @path, name, path

  @read: (constraint, path) ->
    constraint.cache[path] ?= await read @resolve constraint, path

  # this is just here for completeness
  @run: (constraint, pkg, options) ->
    constraint._function constraint, pkg, options

  constructor: (@name) ->
    assign @,
      _function: constraints[@name]
      cache: {}

  resolve: (path) -> Constraint.resolve @, path

  read: (path) -> Constraint.read @, path

  run: (pkg, options) -> Constraint.run @, pkg, options

export default Constraint
