# Reference

This document provides a comprehensive API reference for the Tempo library.

## Introduction to the API

Tempo operates both as a command-line orchestration tool and as a programmatic library via the `Metarepo` object. Both interfaces allow developers to manipulate the workspace, orchestrate lifecycle commands across a polyrepo, and tap into the evolutionary algorithm that manages execution order via failure feedback.

## CLI Commands

The Tempo CLI provides a suite of tools to orchestrate and manage a metarepo directly from the terminal.

### `tempo add`

Registers a new repository to the metarepo configuration and immediately initiates a synchronous clone to pull the source code locally.

**Arguments:**
- `$repo`: The relative path or GitHub repository string (e.g., `dashkite/url-codex`).

<example>
```bash
tempo add dashkite/url-codex
```
</example>

### `tempo remove`

Deregisters a repository from the registry and safely purges its corresponding local directory from the workspace.

**Arguments:**
- `$repo`: The relative path or GitHub repository string.

<example>
```bash
tempo remove dashkite/url-codex
```
</example>

### `tempo clone`

Clones an existing metarepo—along with all its constituent repositories—into the active context, allowing creators to immediately materialize complex projects.

**Arguments:**
- `$metarepo`: The relative path or repository string.
- `--branch $branch`: The branch name to check out.

<example>
```bash
tempo clone dashkite/tempo --branch winterfell
```
</example>

### `tempo sync`

Synchronizes the local workspace by aligning the filesystem state with the defined `repos.yaml` registry. It handles pulling remote metadata, symlinking, cloning newly added repositories, and pruning abandoned projects.

<example>
```bash
tempo sync
```
</example>

### `tempo import`

Imports a batch list of repositories from an external YAML file, appending each to the current metarepo collection and scheduling them for synchronization.

**Arguments:**
- `$path`: The path to a YAML manifest file.

<example>
```bash
tempo import base-repos.yaml
```
</example>

### `tempo exec`

Executes an arbitrary shell command across a dynamic collection of repositories. The execution loop leverages an evolutionary algorithm, intelligently shifting failed operations to subsequent passes to organically resolve complex dependency graphs.

**Arguments:**
- `$command`: The command to execute.
- `--include $include`: YAML file containing repositories to include.
- `--exclude $exclude`: YAML file containing repositories to exclude.
- `--tags $tags`: Tags to include, separated by `+`.
- `--serial`: Run the command for each repository serially.
- `--batch $batch`: Run the command for `$batch` repositories in parallel (default: `6`).
- `--retries $retries`: Allow for `$retries` retries for each repository (default: `6`).
- `--order $order`: Use a partial ordering specified in a YAML or JSON file.
- `--determined`: Re-run the command even if there are persistent failures.

<example>
```bash
tempo exec "pnpm update" --batch 6 --tags core
```
</example>

### `tempo run`

Executes a monadic lifecycle script defined within the `.tempo/scripts.yaml` configuration. This operation relies on the core event-driven architecture, treating the targeted repositories as a unified collection while preserving their distinct boundaries.

**Arguments:**
- `$script`: The name of the script to run.
- `--include $include`: YAML file containing repositories to include.
- `--exclude $exclude`: YAML file containing repositories to exclude.
- `--tags $tags`: Tags to include, separated by `+`.
- `--serial`: Run the command for each repository serially.
- `--batch $batch`: Run the command for `$batch` repositories in parallel (default: `6`).
- `--retries $retries`: Allow for `$retries` retries for each repository (default: `6`).
- `--order $order`: Use a partial ordering specified in a YAML or JSON file.
- `--determined`: Re-run the command even if there are persistent failures.

<example>
```bash
tempo run build --batch 4
```
</example>

### `tempo tag`

Applies specific semantic metadata tags to a repository or a targeted collection of repositories. Tags are critical for limiting the execution scope of future `run` or `exec` commands.

**Arguments:**
- `$tags...`: The tags to apply.
- `--repos $repos...`: The names of individual repositories.
- `--include $include`: YAML file containing repositories to include.
- `--exclude $exclude`: YAML file containing repositories to exclude.

<example>
```bash
tempo tag core module --repos url-codex
```
</example>

### `tempo untag`

Removes specific semantic metadata tags from a repository or a targeted collection of repositories, effectively removing them from targeted lifecycle broadcasts.

**Arguments:**
- `$tags...`: The tags to remove.
- `--repos $repos...`: The names of individual repositories.
- `--include $include`: YAML file containing repositories to include.
- `--exclude $exclude`: YAML file containing repositories to exclude.

<example>
```bash
tempo untag core --repos url-codex
```
</example>

## Metarepo Programmatic API

The `Metarepo` object provides the foundational methods for managing a collection of independent repositories under a single architectural view programmatically.

### initialize

Initializes the `.tempo` workspace directory, configures the internal SQLite caching and registry systems, and establishes standard Git ignore patterns.

**Signature:**
$initialize: () \rightarrow promise$

<example>
This illustrates bootstrapping a fresh Tempo workspace before adding any repositories.
```coffeescript
import Metarepo from "@dashkite/tempo/src/metarepo"

await Metarepo.initialize()
```
</example>

### resolve

Calculates the absolute local file path for a specific repository within the `.tempo` workspace context.

**Signature:**
$resolve: (name) \rightarrow string$

<example>
This illustrates resolving the location of a downloaded dependency.
```coffeescript
path = Metarepo.resolve "url-codex"
```
</example>

### git

Calculates the correct remote Git URL based on the provider (e.g. GitHub or Codeberg), organization namespace, and repository name.

**Signature:**
$git: (options) \rightarrow string$

- `options`: An object containing `provider`, `organization`, and `name` strings.

<example>
This illustrates generating an SSH url for a remote repository.
```coffeescript
url = Metarepo.git 
  provider: "github"
  organization: "dashkite"
  name: "url-codex"
```
</example>

### add

Registers a new repository to the metarepo configuration and immediately initiates a synchronous clone to pull the source code locally.

**Signature:**
$add: (repo) \rightarrow promise$

- `repo`: A string representing the repository path in standard namespace format.

<example>
This illustrates adding a DashKite repository to the current collection.
```coffeescript
await Metarepo.add "dashkite/url-codex"
```
</example>

### remove

Deregisters a repository from the `.tempo/repos.yaml` registry and safely purges its corresponding local directory from the workspace.

**Signature:**
$remove: (repo) \rightarrow promise$

- `repo`: A string representing the repository path in standard namespace format.

<example>
This illustrates cleanly removing a repository that is no longer required.
```coffeescript
await Metarepo.remove "dashkite/url-codex"
```
</example>

### clone

Clones an existing, overarching metarepo—along with all its constituent repositories—into the active context, allowing developers to immediately materialize complex projects.

**Signature:**
$clone: (metarepo, options) \rightarrow promise$

- `metarepo`: A string representing the parent metarepo to retrieve.
- `options`: An object specifying the `branch` string to check out.

<example>
This illustrates cloning a full metarepo onto a specific branch.
```coffeescript
await Metarepo.clone "dashkite/tempo", branch: "winterfell"
```
</example>

### sync

Synchronizes the local workspace by aligning the filesystem state with the defined `repos.yaml` registry. It handles pulling remote metadata, symlinking, cloning newly added repositories, and pruning abandoned projects.

**Signature:**
$sync: () \rightarrow promise$

<example>
This illustrates running a synchronization pass after fetching the latest remote changes.
```coffeescript
await Metarepo.sync()
```
</example>

### prune

Safely evaluates and removes repositories from the local filesystem that exist within the `.tempo` directory but are no longer tracked in the official metarepo registry.

**Signature:**
$prune: () \rightarrow promise$

<example>
This illustrates purging untracked repositories to free up disk space.
```coffeescript
await Metarepo.prune()
```
</example>

### import

Imports a batch list of repositories from an external YAML file, appending each to the current metarepo collection and scheduling them for synchronization.

**Signature:**
$import: (path) \rightarrow promise$

- `path`: A string pointing to the YAML manifest file.

<example>
This illustrates bootstrapping an environment from a predefined manifest.
```coffeescript
await Metarepo.import "base-repos.yaml"
```
</example>

### exec

Executes an arbitrary shell command across a dynamic collection of repositories. The execution loop leverages an evolutionary algorithm, intelligently shifting failed operations to subsequent passes to organically resolve complex dependency graphs.

**Signature:**
$exec: (command, args, options) \rightarrow promise$

- `command`: A string representing the shell command to invoke.
- `args`: An array of argument strings to pass to the command.
- `options`: An object specifying inclusion rules, exclusion rules, targeting `tags`, and a parallelization `batch` integer limit.

<example>
This illustrates broadcasting a parallel package update command across a targeted set of repositories.
```coffeescript
await Metarepo.exec "pnpm update", [], 
  batch: 6
  tags: ["core"]
```
</example>

### run

Executes a monadic lifecycle script defined within the `.tempo/scripts.yaml` configuration. This operation relies on the core event-driven architecture, treating the targeted repositories as a unified collection while preserving their distinct git boundaries.

**Signature:**
$run: (script, args, options) \rightarrow promise$

- `script`: A string identifying the configuration script block to run.
- `args`: An array of positional argument strings mapped to the script.
- `options`: An object configuring batch limits, retries, and targeting options.

<example>
This illustrates triggering a custom build script concurrently.
```coffeescript
await Metarepo.run "build", [], batch: 4
```
</example>

### tag

Applies specific semantic metadata tags to a repository or a targeted collection of repositories. Tags are critical for limiting the execution scope of future `run` or `exec` commands.

**Signature:**
$tag: (tags, options) \rightarrow promise$

- `tags`: An array of string labels to apply.
- `options`: An object specifying the target `repos` to tag.

<example>
This illustrates tagging a repository for future targeting.
```coffeescript
await Metarepo.tag ["core", "module"], repos: ["url-codex"]
```
</example>

### untag

Removes specific semantic metadata tags from a repository or a targeted collection of repositories, effectively removing them from targeted lifecycle broadcasts.

**Signature:**
$untag: (tags, options) \rightarrow promise$

- `tags`: An array of string labels to remove.
- `options`: An object specifying the target `repos` to update.

<example>
This illustrates cleaning up obsolete tags from a module.
```coffeescript
await Metarepo.untag ["core"], repos: ["url-codex"]
```
</example>
