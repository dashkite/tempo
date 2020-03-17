import {resolve, extname} from "path"
import {identity} from "panda-garden"
import {assign} from "panda-parchment"
import {read} from "panda-quill"

serializer = (extension) ->
  switch extension[1..]
    when "json"
      fromString: JSON.parse
      toString: JSON.stringify
    when "yaml"
      fromString: YAML.safeLoad
      toString: YAML.safeDump
    else
      fromString: identity
      toString: identity

class Package

  @create: (options) -> new Package options

  @resolve: (pkg, path) -> resolve pkg.path, path

  @read: (pkg, path) ->
    pkg.cache[path] ?= do =>
      content = await read @resolve pkg, path
      {fromString} = serializer extname path
      data = fromString content
      {content, data}

  constructor: ({@path, @scope, @git, @constraints}) ->
    assign @, errors: []
    @constraints ?= []
    @cache = {}

  resolve: (path) -> Package.resolve @, path

  read: (path) -> Package.read @, path

export default Package
