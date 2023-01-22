# Tempo
*Metarepo project and package management.*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

You’ve heard of monorepos? A *metarepo* (also referred to as a *polyrepo*) is similar except that it doesn’t require everything to be in a single repo. (Hat tip to the creators of [Meta](https://github.com/mateodelnorte/meta) for both the term _metarepo_ and for influencing Tempo.) Instead, you create a repo that _references_ a collection of existing repos and perform operations against them together. Basically, it’s the best of both worlds: the benefits of a monorepo without the drawbacks.

## Installation

```
npm i -g @dashkite/tempo
```

## Usage

```
Usage: tempo [options] [command]

Options:
  -h, --help                               display help for command

Commands:
  add|a <repo>                             Add a project to a metarepo
  remove|rm <repo>                         Remove a project from a metarepo
  clone <metarepo>                         Clone a metarepo
  sync                                     Sync a metarepo with remote
  import <path>                            Import respositories from a list
  exec [options] <command> [arguments...]  Run a command across repos
  run [options] <script> [arguments...]    Run a Tempo script
  help [command]                           display help for command
```

### Create A Metarepo

You can create a new metarepo by simply creating a new repo.

### Add A Repo

To add another repo to your metarepo, use the `add` subcommand with a GitHub repo path:

```
tempo add dashkite/url-codex
```

### Remove A Repo

You can similarly remove a repo with `remove`.

### Importing Repos

You can add a bunch of repos all at once with `import`:

```
tempo import repos.yaml
```

The input file should contain a YAML encoded array of GitHub repo paths.

### Cloning A Metarepo

To work from an existing metarepo, use `clone` with the GitHub repo path:

```
tempo clone vedic-dolphin
```

This will clone the metarepo and all the metarepos it contains.

### Synchronizing Metarepos

You can sync meta repos—which is equivalent to pulling and adding/removing repos—using the `sync` command.

### Running Commands

You can run arbitrary commands across all the repos in a metarepo with `exec`:

```
tempo exec git pull
```

You can also define scripts for more complex commands and run them using the `run` command:

```
tempo run pull
```

Both `run` and `exec` allow you to use files to target a subset of repos with the `targets` option:

```
tempo run --targets core.yaml build
```

Targeting files should be YAML arrays with only the repo names (not the relative path).

### Defining Run Scripts

Run scripts are defined in `scripts` property of the `tempo.yaml` file. Positional arguments can be applied using `$` and index of the argument. You can reference all the arguments together with `$@`.

For example, to define a commit command that takes a commit message, you might have a `tempo.yaml` file that looks something like this:

```yaml
scripts:
  commit: git add -A . && git commit -m '$0'
repos:
  # ...
```

## Scenarios

### Targeting Repos

You can use [`jq`](https://stedolan.github.io/jq/) and [`yq`](https://mikefarah.gitbook.io/yq/) to query your repos and target `run` or `exec` commands.

For example, to update a specific dependency, we want to target repos that have that dependency. The most direct way to do that is to use `exec` and the `-e` option of `jq` to chain the commands with `&&`. However, this gets messy because of the levels of quoting involved. Instead, we would add a script, which also allows us to make it more general:

```yaml
scripts:
  update: jq -e '.dependencies["$0"]' package.json && pnpm add $0@latest
```

We can thus run:

```
tempo run update @dashkite/url-codex
```

However, sometimes the queries are more complex, in which case we can use `jq` or `yq` to build a list that we can pass to `run` (or `exec`) instead. Of course, we can use any tool to build our list, or even simply compile it manually.

## Roadmap

- **Logging:** Allow output to be directed to a file so that the output for a given command and repo can be reviewed.
- **Parallelism:** Allow for parallel execution of `run` or `exec` commands. Requires logging.
- **Queries:** Integrate `jq`/`yq`-like support directly.
- **Include/Exclude:** Allow direct targeting of commands.
- **Script options:** Allow options to be specified and parameterized alongside scripts.
