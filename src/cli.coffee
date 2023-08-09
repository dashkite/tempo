import { program, Command } from "commander"
import Metarepo from "./metarepo"

program
  # TODO get version from package.json
  # .version version
  .enablePositionalOptions()

program
  .command "add"
  .description "Add a project to a metarepo"
  .alias "a"
  .argument "<repo>", "The relative path of the repo"
  .action Metarepo.add

program
  .command "remove"
  .description "Remove a project from a metarepo"
  .aliases [ "rm", "del", "delete" ]
  .argument "<repo>", "The relative path of the repo"
  .action Metarepo.remove
  
program
  .command "clone"
  .description "Clone a metarepo"
  .argument "<metarepo>", "The relative path of the repo"
  .action Metarepo.clone

program
  .command "sync"
  .description "Sync a metarepo with remote"
  .action Metarepo.sync

program
  .command "import"
  .description "Import respositories from a list"
  .argument "<path>", "The path of the import file"
  .action Metarepo.import

program
  .command "exec"
  .description "Run a command across repos"
  .option "-t, --targets <targets>", "YAML file containing repos to target"
  .option "-s, --serial", "Run command for each repo serially", false
  .passThroughOptions()
  .argument "<command>", "The command to run"
  .argument "[arguments...]", "Arguments to pass, if any"
  .action Metarepo.exec

program
  .command "run"
  .description "Run a Tempo script"
  .option "-t, --targets <targets>", "YAML file containing repos to target"
  .option "-s, --serial", "Run command for each repo serially", false
  .argument "<script>", "The script to run"
  .argument "[arguments...]", "Arguments to pass, if any"
  .action Metarepo.run

program.parseAsync()