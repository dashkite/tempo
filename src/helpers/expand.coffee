# TODO make variable substition more robust
# TODO remove this feature in favor of env vars?
expand = ( text, argv ) ->
  text
    .replaceAll /\$(\d)/g, ( _, i ) ->
      if argv[i]?
        argv[i]
      else
        throw new Error "tempo: missing positional argument $#{i}"
    .replaceAll /\$@/g, -> argv.join " "


export { expand }