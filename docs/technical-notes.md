# Technical Notes

This document contains detailed architectural notes, core philosophies, and algorithm breakdowns for the Tempo repository.

## The Metarepo Philosophy

### Contrasting Metarepos, Monorepos, and Polyrepos

The [*monorepo*](https://en.wikipedia.org/wiki/Monorepo) concept organizes a group of independent Git repositories by recognizing their interrelationships. It acknowledges the utility of shared commands to build, test, and maintain these projects together. However, the central conceit is that these are somehow independent repositories, despite being lodged in the "one true" repository.

Conversely, a [*polyrepo*](https://en.wikipedia.org/wiki/Multi-repo_software_architecture) (or multi-repo) acknowledges that the constituent repositories are truly distinct and allows teams to operate autonomously. But under this model, coordinating cross-repository dependencies still introduces a degree of unmanaged complexity. 

DashKite's philosophy embraces irreducible complexity, carefully framing it to allow creators to attack the problem directly. This is where the *metarepo* concept shines. Repositories are separated, as they are with the polyrepo, but a new repository is introduced with the sole purpose of supporting workspace management. This new repository contains symbolic links to the repositories that get installed, alongside dedicated code, configuration, and scripting for modeling the project as a whole.

### The Accessor Pattern

This architectural approach shares a lot in common with DashKite's accessor pattern usage. The constituent repositories are a fact of reality; the metarepo is simply a particular view on a specific collection of repositories.

That acknowledgment of a collection is central. Where the monorepo pattern requires a conceit that non-independent directories are distinct repositories, modeling them as a collection of repositories relieves the creator of that suspension of disbelief. 

### Monadic Design in Lifecycle Commands

When taking action—such as a build action—on a collection of repositories, the algorithm becomes as simple as iterating through a list of repositories and triggering their commands. That naturally encourages [monadic design](https://en.wikipedia.org/wiki/Monad_(functional_programming)) in the project commands. 

This is exactly what is seen in the `genie` lifecycle commands. Genie acts as an orchestration tool employing an [event-driven architecture](https://en.wikipedia.org/wiki/Event-driven_architecture) to execute task handlers. All the `genie` presets are built around primary lifecycle events (`clean`, `build`, `test`, `release`, `publish`) as a general way to think about a repository in the abstract. 

By utilizing these standardized lifecycle hooks, Genie presets (such as `genie-clean` or `genie-coffee`) automatically bind internal tasks to the standard lifecycle. For example, when a creator invokes `npx genie clean`, Genie triggers the event listener which delegates to Masonry for the actual file deletion. The developer interacts with this module exclusively through these lifecycle hooks, abstracting the operations cleanly.

This architectural alignment allows Tempo to be a relatively simple library. It relies on this collection of repositories idea to build up its operating model, allowing Tempo-managed projects to be made of loosely coupled repositories. Furthermore, it exposes the worthy problem of [dependency graph](https://en.wikipedia.org/wiki/Dependency_graph) management, instead of papering over it by advancing all the constituent repositories together as a single structure.

### Configuration Management via yq

Tempo heavily utilizes YAML configuration files (such as `.tempo/repos.yaml` and `.tempo/scripts.yaml`) for maintaining the repository registry, custom lifecycle scripts, and targeting rules. Rather than inventing a custom configuration utility, Tempo embraces the UNIX philosophy by encouraging developers to use the [`yq` CLI](https://mikefarah.gitbook.io/yq/) to efficiently manage these configuration files. `yq` serves as an effective command-line YAML processor for querying registry fields, bulk-updating tags, and filtering objects directly in place.

## Run Algorithm Architecture

Because dependency graphs can be difficult to calculate directly, Tempo relies on an [evolutionary algorithm](https://en.wikipedia.org/wiki/Evolutionary_algorithm) to achieve a settling of behavior.

### Initialization Phase

The main loop handles executing commands across multiple repositories. It starts by destructuring the options and determining the ordering of repositories. If an order is provided, it is read and evaluated. Otherwise, a default trivial group is created by randomly shuffling the list of repositories.

It checks for missing repositories and adds them to the first group, then filters the groups to include only the target repositories and removes empty groups. The algorithm maintains state variables such as `succeeded` (a set of completed repositories), `history` (hashes of previous failures to prevent infinite loops), and `failures` (a dictionary tracking failure counts).

### Evolutionary Execution Loop

The core loop iterates until the `done` flag is set. Inside the loop, it iterates through the generated groups. 
For each group, it enqueues the tasks using a `limiter` function. This function employs a [Bounded Semaphore](https://en.wikipedia.org/wiki/Semaphore_(programming)) via the `p-limit` library to manage concurrency. By batching operations and limiting parallel execution, the system ensures high throughput without overwhelming the host environment with too many concurrent processes.

If a repository fails its task, it is placed into a `failed` array. If the task succeeds without throwing an error, the repository is added to the `succeeded` set. The progress is reflected via a progress bar UI updated after each iteration.

### Failure as Semantic Feedback

If failures occur within a group, the algorithm employs a `mulligan` system. If a mulligan is available, the current group is retried immediately to gracefully handle transient errors. 

If no mulligan is available, the failed repositories are "demoted" to the next group, allowing them to be retried in a subsequent pass, provided their failure count has not exceeded the configured `retries` limit. Tasks that cannot be completed are shifted to the next pass and tried again, somewhat similar to Athena's nested loop, looking for a settling of behavior.

What is notable here is that even though Tempo uses an evolutionary algorithm, it is surprisingly simple because it incorporates failure information as a feedback mechanism. This represents a philosophy of automation that does not automatically assume failure is a terminal condition, but rather one with semantic value that can possibly drive further automation and eventual resolution.
