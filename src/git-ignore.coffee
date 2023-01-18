import FS from "node:fs/promises"

GitIgnore =

  load: ->
    try
      text = await FS.readFile ".gitignore", "utf8"
    catch
      text = ""
    new Set text.split "\n"

  save: ( ignored ) ->
    FS.writeFile ".gitignore",
      Array
        .from ignored
        .join "\n"

  add: ( name ) ->
    ignored = await GitIgnore.load()
    ignored.add name
    GitIgnore.save ignored

  remove: ( name ) ->
    ignored = await GitIgnore.load()
    ignored.delete name
    GitIgnore.save ignored
  

export default GitIgnore