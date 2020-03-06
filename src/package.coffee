class Package

  @create: (options) -> new Package options

  constructor: ({@path, @git, @constraints}) ->
    Object.assign @,
      actions: []
      updates: {}
      results: {}
      errors: []
      cache:
        content: {}
        data: {}

export default Package
