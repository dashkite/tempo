# Recipes

This document provides step-by-step guides for executing common tasks using the Tempo metarepo management tool.

## CLI Recipes

This section outlines how to orchestrate a metarepo directly from the terminal, progressing from fundamental workspace initialization to complex targeted script broadcasting and dependency resolution.

### How to initialize and populate a metarepo?

The creator can establish a metarepo by initializing a standard repository and linking child repositories into it. This approach enables global orchestration without directly coupling the codebases.

1.  Initialize the overarching parent repository using Git.
2.  Use the `tempo add` command to link individual child repositories by their namespace.
3.  Alternatively, if migrating an entire organization, use `tempo import` with a YAML list of repositories.
4.  Observe that Tempo creates a `.tempo` directory containing the `repos.yaml` configuration.

<example>
```bash
# Add a single repository
tempo add dashkite/url-codex

# Import a bulk list of repositories from a manifest
tempo import base-repos.yaml
```
</example>

### How to clone an existing metarepo?

When joining a project, the developer can instantly materialize an entire metarepo hierarchy locally using a single command.

1.  Identify the target metarepo namespace.
2.  Execute the `tempo clone` command to pull the parent repository and recursively clone all its registered constituent repositories.
3.  Optionally, specify a branch to ensure all repositories align to a specific release line.

<example>
```bash
# Clone the entire tempo metarepo on the winterfell branch
tempo clone dashkite/tempo --branch winterfell
```
</example>

### How to keep the workspace synchronized?

The developer MUST ensure their local filesystem reflects the remote truth of the metarepo registry.

1.  Pull the latest upstream changes in the root metarepo directory.
2.  Run the `tempo sync` command.
3.  Tempo will automatically evaluate the registry, clone any newly added child repositories, and prune those that have been removed.

<example>
```bash
# Synchronize local folders with the current registry
tempo sync
```
</example>

### How to broadcast simple commands?

The creator can execute arbitrary shell commands across all child repositories within the metarepo simultaneously. This is particularly useful for global updates or status checks.

1.  Verify that the metarepo has been fully synchronized.
2.  Use the `tempo exec` command followed by the desired shell command to run it concurrently in every child directory.

<example>
```bash
# Pull the latest changes across all repositories
tempo exec git pull

# Install dependencies across all repositories
tempo exec pnpm install
```
</example>

### How to define and trigger custom scripts?

The creator can define complex, reusable workflows within the `.tempo/scripts.yaml` configuration file and execute them across the metarepo using the `tempo run` command.

1.  Create or edit the `.tempo/scripts.yaml` file.
2.  Define a script key mapping to the command to execute. Positional arguments are available as `$0`, `$1`, etc.
3.  Invoke the script using `tempo run` with the target key.

<example>
This illustrates defining a commit script and running it across all repositories.
```yaml
# .tempo/scripts.yaml
commit: git add -A . && git commit -m '$0'
```

```bash
# Run the commit script with a message argument
tempo run commit "Update dependencies"
```
</example>

### How to query and update workspace configuration?

Tempo utilizes YAML configuration files for maintaining the repository list, custom scripts, and targeting rules. The developer MAY use the `yq` CLI to efficiently manage these configuration files.

1.  Install `yq` on your system.
2.  Target the `.tempo/repos.yaml` or `.tempo/scripts.yaml` file to query or update data in place.
3.  Use standard `yq` filters to mutate specific repository entries, such as bulk-adding tags.

<example>
```bash
# Extract the provider for a specific repository
yq '.[] | select(.name == "url-codex") | .provider' .tempo/repos.yaml

# Append a tag to a repository in place
yq -i '.[] | select(.name == "url-codex") | .tags += ["core"]' .tempo/repos.yaml
```
</example>

### How to target specific subsets of repositories?

The developer can restrict execution to a subset of repositories by applying metadata tags or specific inclusion files, thereby limiting the scope of operations to relevant projects.

1.  Apply semantic tags to specific repositories using the `tempo tag` command.
2.  Run the target command using the `--tags` flag to filter execution.
3.  To remove a repository from future targeting, use `tempo untag`.

<example>
```bash
# Tag specific repositories
tempo tag core module --repos url-codex

# Run a build script only on the tagged repositories
tempo run build --tags module

# Remove the obsolete tag
tempo untag core --repos url-codex
```
</example>

Alternatively, the developer can provide a YAML file listing specific repositories to include or exclude ad hoc.

<example>
```bash
# Execute tests only on repositories explicitly listed in core.yaml
tempo exec "genie test" --include core.yaml
```
</example>

### How to organically resolve complex dependency graphs?

When executing lifecycle commands (like builds) that implicitly depend on the completion of other repositories, the developer can leverage Tempo's evolutionary algorithm to automatically settle the dependency graph through failure feedback.

1.  Determine the operation that may fail due to unmet downstream dependencies.
2.  Invoke the command with the `--determined` flag to continuously loop and retry failed repositories.
3.  Optionally provide a partial `--order` file to bias the initial pass, or adjust `--retries` and `--batch` size to fine-tune the concurrency limit.

<example>
```bash
# Run a build pass that retries failed repos until the entire graph succeeds
tempo run build --determined --batch 4 --retries 10
```
</example>

## Programmatic Recipes

This section outlines how to interact with the `Metarepo` object programmatically, allowing creators to integrate Tempo into custom Node.js automation scripts or deeper tooling.

### How to bootstrap a programmatic workspace?

The developer can orchestrate a metarepo entirely from a Node.js context by initializing the environment and invoking registry commands directly.

1.  Import the `Metarepo` object from the Tempo source.
2.  Call the `initialize` method to prepare the `.tempo` directory and caching layer.
3.  Use the `add` method to programmatically register and clone a repository.

<example>
```coffeescript
import Metarepo from "@dashkite/tempo/src/metarepo"

await Metarepo.initialize()
await Metarepo.add "dashkite/url-codex"
```
</example>

### How to orchestrate programmatic lifecycle events?

The developer can leverage the underlying evolutionary run algorithm directly through the API to construct advanced, resilient task pipelines.

1.  Ensure the target command or script is defined.
2.  Invoke `Metarepo.exec` or `Metarepo.run`, passing the command, arguments, and a configuration object governing batch limits and targeting.

<example>
```coffeescript
# Execute a targeted build, limiting concurrency to 2 instances
await Metarepo.run "build", [], 
  batch: 2
  tags: [ "module" ]
  determined: true
```
</example>

### How to maintain the local registry programmatically?

The developer can build synchronization utilities that ensure the local filesystem remains in lockstep with the remote configuration.

1.  Invoke `Metarepo.sync` to handle the standard clone, pull, and symlink routine.
2.  Invoke `Metarepo.prune` to explicitly garbage collect local repositories that have been removed from the registry.

<example>
```coffeescript
# Keep the workspace perfectly aligned with the remote truth
await Metarepo.sync()
await Metarepo.prune()
```
</example>
