import { program, Command } from "commander"
import Metarepo from "./metarepo"

# TODO get version from package.json
# program
#   .version version

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
  .alias "sync"
  .description "Clone any missing repositories"
  .action Metarepo.clone

program
  .command "import"
  .description "Import respositories from a list"
  .argument "<path>", "The path of the import file"
  .action Metarepo.import

program.parseAsync()