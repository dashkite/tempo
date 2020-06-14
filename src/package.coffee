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
    pkg.cache[path] ?= await do =>
      {fromString} = serializer extname path
      content = await read @resolve pkg, path
      data = fromString content
      {content, data}

  # this is a proposed write: must explicitly write to files
  @write: (pkg, path, {content, data}) ->

    {fromString, toString} = serializer extname path

    # at least one of these must be defined
    # we can derive one from the other if necessary
    if content? || data?
      data ?= fromString content
      content ?= toString data
      pkg.cache[path] = {content, data}
      pkg.updates[path] = content

  constructor: ({@path, @scope, @git, @exemplars}) ->
    assign @, errors: []
    @exemplars ?= []
    @cache = {}
    @updates = {}

  resolve: (path) -> Package.resolve @, path

  read: (path) -> Package.read @, path

  write: (path, value) -> Package.write @, path, value

  commit: -> Package.commit @

export default Package
