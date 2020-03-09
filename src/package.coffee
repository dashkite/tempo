import {resolve} from "path"
import {assign} from "panda-parchment"

class Package

  @create: (options) -> new Package options

  @resolve: (pkg, path) -> resolve pkg.path, path

  constructor: ({@path, @git, @constraints}) -> assign @, errors: []

  resolve: (path) -> Package.resolve @, path

export default Package
