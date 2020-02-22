# Panda Builder

Shared tooling for building packages, among others.

## Conventions

- Source code is in `src` (not `lib`)
- Tests are in `test`
- Build artifacts are in `build`
- Build artifacts are checked in to git
- Build targets have their own subdirectories, ex: `build/npm`
- Each release is tagged

## Usage

```
tools = require "fairmont-build-tools"
{target} = tools require "gulp"

target "npm"
```

This will get you the tasks associated with the `npm` target preset. This includes:

- `npm:build` — Compiles CoffeeScript in `lib` to `build/npm/lib` and CoffeeScript tests in `test` to `build/npm/test`.

- `npm:test` — Runs the compiled tests.

- `npm publish` — Publishes to NPM.

## Presets

The only meaningful preset at this time `npm`. Presets `esm` and `www` are reserved. Don't use these as tasks prefixes.

## Built-In Tasks

The tasks `build`, `test`, and `publish` are all defined to iterate on active targets (any targets for which tasks have been defined) and execute the corresponding tasks, ex: `npm:build`.

In addition, these tasks are also defined:

- `git:tag` — Tag the current release using the version in the `package.json` file and push the tags to master. Runs automatically on `npm:publish`.

- `clean` — Deletes the entire `build` directory. Since each target defines it's own clean task (which should delete the target directory), you shouldn't need this.

## Configuring `package.json`

The files you're publishing will be in `build/npm`. The `files`, `directories`, and `main` properties should reflect this. Define `test` to be `gulp test`.

## Initializing Projects

You can automatically set up your project to use Panda Builder.

```
npm i -D panda-builder
npx panda-builder-init
```

This will set up a LICENSE file, a template README, `src` and `test` directories, the Gulpfiles you'll need to import Builder's Gulp tasks, install the necessary dependencies, and update `package.json` accordingly.

`panda-builder-init` will not overwrite files that are already there, but will overwrite `package.json` entries for `main`,  `license`, and the `test` script.

## Watching Files

Coming soon.
