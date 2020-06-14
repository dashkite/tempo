import {resolve} from "path"
import {read} from "panda-quill"
import log from "./log"

class Exemplar

  @dictionary: {}

  @create: (name, module) ->
    @dictionary[name] = new Exemplar name, module

  @resolve: (exemplar, path) -> exemplar.resolve path

  @read: (exemplar, path) -> exemplar.read path

  @run: (name, pkg, options) ->
    Exemplar.dictionary[name].run pkg, options

  constructor: (@name, @module) ->
    @path = require.resolve @module
    @run = (require @reference)(log)
    @_cache = {}

  resolve: (path) -> resolve @path, path

  read: (path) -> @_cache[path] ?= await read @resolve path

export default Exemplar
