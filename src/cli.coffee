import FS from "node:fs"
import Path from "node:path"
import { program } from "commander"
import Metarepo from "./metarepo"
import Command from "./command"

Tags =
  
  parse: ( tags ) -> tags.split "+"

program
  # TODO get version from package.json
  .version do ({ path, json, pkg } = {}) ->
    path = Path.join __dirname, "..", "..", "..", "package.json"
    json = FS.readFileSync path, "utf8"
    pkg = JSON.parse json
    pkg.version
  .enablePositionalOptions()

program
  .command "add"
  .description "add a project to a metarepo"
  .alias "a"
  .argument "<repo>", "The relative path of the repo"
  .action Command.wrap Metarepo.add

program
  .command "remove"
  .description "aemove a project from a metarepo"
  .aliases [ "rm", "del", "delete" ]
  .argument "<repo>", "The relative path of the repo"
  .action Command.wrap Metarepo.remove
  
program
  .command "clone"
  .description "clone a metarepo"
  .argument "<metarepo>", "The relative path of the repo"
  .action Command.wrap Metarepo.clone

program
  .command "sync"
  .description "sync a metarepo with remote"
  .action Command.wrap Metarepo.sync

program
  .command "import"
  .description "import respositories from a list"
  .argument "<path>", "The path of the import file"
  .action Command.wrap Metarepo.import

program
  .command "exec"
  .description "run a command across repos"
  .option "-i, --include <include>", "YAML file containing repos to include"
  .option "-x, --exclude <exclude>", "YAML file containing repos to exclude"
  .option "-t, --tags <tags>", "Tags to include, separated by +", Tags.parse
  .option "-s, --serial", "Run command for each repo serially"
  .option "-P, --no-progress", "Don't show progress bar"
  .passThroughOptions()
  .argument "<command>", "The command to run"
  .argument "[arguments...]", "Arguments to pass, if any"
  .action Command.wrap Metarepo.exec

program
  .command "run"
  .description "run a saved script"
  .option "-i, --include <include>", "YAML or JSON file of repos to include"
  .option "-x, --exclude <exclude>", "YAML or JSON file of repos to exclude"
  .option "-t, --tags <tags>", "Tags to include, separated by +", Tags.parse
  .option "-s, --serial", "Run command for each repo serially"
  .option "-P, --no-progress", "Don't show progress bar"
  .argument "<script>", "The script to run"
  .argument "[arguments...]", "Arguments to pass, if any"
  .action Command.wrap Metarepo.run

program
  .command "tag"
  .description "add tags to a repository"
  .option "-r, --repo <repos...>", "The name of an individual repo"
  .option "-i, --include <include>", "YAML or JSON file of repos to include"
  .option "-x, --exclude <exclude>", "YAML or JSON file of repos to exclude"
  .argument "<tags...>", "The tags to apply to a set of repos"
  .action Command.wrap Metarepo.tag

program
  .command "untag"
  .description "remove tags from a repository"
  .option "-r, --repo <repos...>", "The name of an individual repo"
  .option "-i, --include <include>", "YAML or JSON file of repos to include"
  .option "-x, --exclude <exclude>", "YAML or JSON file of repos to exclude"
  .argument "<tags...>", "The tags to apply to a set of repos"
  .action Command.wrap Metarepo.tag

for command in program.commands
  command
    .option "-v, --verbose", "Perform debug logging"
    .option "-l, --logfile <filename>", "Stream log to a file"

program.parseAsync()