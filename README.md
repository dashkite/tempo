# Tempo
*Polyrepo project and package management.*

Define projects and actions in YAML and run the actions across all projects.

## Example

Automatically checkout a given branch across all projects.

### Action File

```yaml
actions:
  - git checkout ${branch}
```

### Projects File

```yaml
env:
  branch: foo
paths:
  - bar
  - baz
```

Then run Tempo:

```shell
tempo -a actions.yaml -p projects.yaml
```

## Install

```shell
npm i -g @dashkite/tempo
```

## Features

### Github Integration

If you specify an organization in a project file, Tempo uses that to clone missing project directories.

## Roadmap

Tempo is currently pretty basic. Features we may add:

- Run commands from “scratch” in a temporary directory
- Better logging, ability to control level
- Command types (ex: copying a file, so that not everything has to be a task)
- Improved Genie integration (becomes a command type)
- Improved Git integration (becomes a command type)
- And more!
