usage = ->
  console.log """

    Usage: tempo [ description ] [ options ]

    Run a list of commands against a list of repos. You may
    provide either a path to a description file or options.

    Options:

        --actions <actions>        Path to the actions file    
        -a <actions>               Alias for --actions
        --project <project>        Path to the project file
        -p <project>               Alias for --project
        -h, --help                 Display this help

    """
  process.exit 1

export default usage