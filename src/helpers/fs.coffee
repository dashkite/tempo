import FS from "node:fs/promises"

isDirectory = ( name ) ->
  try
    ( await FS.stat name ).isDirectory()
  catch
    false

export { isDirectory }