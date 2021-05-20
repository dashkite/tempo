# Tempo
*Polyrepo project and package management.*

Define a set of projects and actions in YAML:

```yaml
paths:
- foo
- bar
env:
  version: patch
actions:
- build
- test
- release
```

Then run Tempo:

```shell
tempo tasks.yaml
```

## Install

```shell
npm i -g @dashkite/tempo
```

## Roadmap

Tempo is currently pretty basic. Features we may add:

- Reference GitHub projects instead of paths
- Run commands from “scratch” in a temporary directory
- Better logging, ability to control level
- Command types (ex: copying a file, so that not everything has to be a task)
- Improved Genie integration (becomes a command type)
- Command sets, so you can control which actions are run for a set of files
- And more!