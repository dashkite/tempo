import FS from "node:fs"
import Path from "node:path"
import { program, Command } from "commander"
import Metarepo from "./metarepo"

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
  .action Metarepo.add

program
  .command "remove"
  .description "aemove a project from a metarepo"
  .aliases [ "rm", "del", "delete" ]
  .argument "<repo>", "The relative path of the repo"
  .action Metarepo.remove
  
program
  .command "clone"
  .description "clone a metarepo"
  .argument "<metarepo>", "The relative path of the repo"
  .action Metarepo.clone

program
  .command "sync"
  .description "sync a metarepo with remote"
  .action Metarepo.sync

program
  .command "import"
  .description "import respositories from a list"
  .argument "<path>", "The path of the import file"
  .action Metarepo.import

program
  .command "exec"
  .description "run a command across repos"
  .option "-i, --include <include>", "YAML file containing repos to include"
  .option "-x, --exclude <exclude>", "YAML file containing repos to exclude"
  .option "-t, --tags <tags>", "Tags to include, separated by +"
  .option "-s, --serial", "Run command for each repo serially", false
  .option "-g, --groups <groups>", "YAML file containing grouped repos"
  .passThroughOptions()
  .argument "<command>", "The command to run"
  .argument "[arguments...]", "Arguments to pass, if any"
  .action Metarepo.exec

program
  .command "run"
  .description "run a saved script"
  .option "-i, --include <include>", "YAML file containing repos to include"
  .option "-x, --exclude <exclude>", "YAML file containing repos to exclude"
  .option "-t, --tags <tags>", "Tags to include, separated by +"
  .option "-s, --serial", "Run command for each repo serially", false
  .option "-g, --groups <groups>", "YAML file containing grouped repos"
  .argument "<script>", "The script to run"
  .argument "[arguments...]", "Arguments to pass, if any"
  .action Metarepo.run

program
  .command "tag"
  .description "tag a repository"
  .option "-r, --repo <name>", "The name of an individual repo"
  .option "-i, --include <include>", "YAML file containing repos to include"
  .option "-x, --exclude <exclude>", "YAML file containing repos to exclude"
  .option "-d, --delete", "Delete tags"
  .argument "<tags...>", "The tags to apply to a set of repos"
  .action Metarepo.tag

program.parseAsync()