Repo = 
  parse: ( repo ) ->
    [ organization, name ] = repo.split "/"
    { organization, name }

export default Repo