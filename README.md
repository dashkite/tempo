# Tempo
*Metarepo project and package management.*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

Tempo is a robust command-line tool designed for managing a *metarepo* (or polyrepo). It allows the developer to orchestrate operations across multiple distinct repositories as if they were a single monorepo, without the downsides of combining their version control histories.

## Features

- Manage a centralized registry of repositories within a single parent directory.
- Broadcast arbitrary shell commands across all or a subset of repositories.
- Execute operations in parallel with configurable batch sizing.
- Filter operations using tags, inclusion lists, or exclusion lists.
- Define custom reusable scripts with positional arguments.
- Intelligently retry failed operations with a determined execution loop.

## Installation

Install the `@dashkite/tempo` package globally using `npm` or `pnpm`.

```bash
pnpm install -g @dashkite/tempo
```

## Usage

Once installed, the `tempo` CLI is available for orchestrating your metarepo.

To create a new metarepo, simply initialize a standard Git repository. Then, add child repositories using the `add` command:

```bash
tempo add dashkite/url-codex
```

You can then broadcast commands across the metarepo using `exec`:

```bash
tempo exec git pull
```

## Other Resources

- [API Reference](docs/reference.md)
- [Usage Recipes](docs/recipes.md)
- [Technical Notes](docs/technical-notes.md)
- [Testing Guidelines](docs/testing.md)
