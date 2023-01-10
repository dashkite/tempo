fatal = ( message ) ->
  console.error "tempo: #{ message }"
  process.exit 1

export { fatal }