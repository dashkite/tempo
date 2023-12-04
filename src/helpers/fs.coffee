import FS from "node:fs/promises"

FSX =
  isDirectory: ( name ) ->
    try
      ( await FS.stat name ).isDirectory()
    catch
      false

export { FSX }