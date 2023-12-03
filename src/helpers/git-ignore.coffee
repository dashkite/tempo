import Zephyr from "@dashkite/zephyr"

GitIgnore =

  load: ->
    text = await Zephyr.read ".gitignore"
    new Set text.split "\n"

  save: ( ignored ) ->
    Zephyr.write ".gitignore", 
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
  
export { GitIgnore }
export default GitIgnore