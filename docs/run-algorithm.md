# The Run Algorithm

In what follows, I break down the main run algorithm as its currently written.

We start by destructuring the options produced by the CLI processing, reading in the ordering file, if provided, and other providing a default by randomly shuffling the list of repos.

```coffeescript
run ({ repos, command, key, retries, order, batch, determined }) ->

  if order?
    groups = await Zephyr.read order

  # default the trivial group
  groups ?= [ Arr.shuffle ( repos.map ({ name }) -> name ) ]
```

Next, we update the groups to account for missing or extraneous repos.

> [!Note]
>
> We only need to do this when an ordering is provided, so we could move this code up under the `if order?` conditiona.

```coffeescript
  # check for missing repos
  # add to first group if we find any
  for repo in repos
    found = ( groups.find ( group ) -> repo.name in group )?
    unless found
      push groups[ 0 ], repo.name
  
  groups = groups
    # remove repos that are not in the target repos list
    .map ( group ) ->
      group.filter ( name ) ->
        ( repos.find ( repo ) -> repo.name == name )?
    # remove empty groups since they will halt the run loop
    .filter ( group ) -> group.length != 0
```

Now that we have a partial ordering in `groups`—possibly the trivial ordering with just one group—we're ready for initialization. Let's go through each of these variables and their purpose:

| Variable    | Description                                                  | Comments                                                     |
| ----------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `succeeded` | Tracks of all the repos for which we've successfully run the task. | This isn't stricly necessary to initialize here. We originally had a `done` function and initialization to `undefined` ensured that it was in its closure. |
| `hash`      | The hash of the current set of failures.                     | Similar to `succeeded`, we’re just making the scope explicit. We could probably remove the initialization. |
| `history`   | A history of hashes we’ve generated in past iterations.      | The `hash` and `history` provide one way to detect failure: if we’ve seen this same set of failures before, we’re probably stuck. |
| `failures`  | A dictionary of failure counts.                              | NA                                                           |
| `limiter`   | A function that enqueues functions to be run in batches.     | We use this to tune parallelization based on a batch size option. |
| `count`     | The number of iterations that have been run so far.          | NA                                                           |
| `done`      | Whether we’re finished running all the tasks, whether because they’ve all run successfully or because we can’t make further progress. | NA                                                           |

```coffeescript
  succeeded = undefined
  hash = undefined
  history = []
  # initialize failures lookup
  failures = {}
  ( failures[ repo.name ] = 0 ) for repo in repos  

  log.info 
    console: true
    message: "Running [ #{ Text.elide 40, "...", command } ]"
    command: command

  limiter = pLimit batch

  count = 0
  done = false
```

  With the initialization out of the way, we're ready to enter into the main loop.

  ```coffeescript
  while !done
  ```

  First, if we're past our first run, the ordering we were given didn't work out, so we abandon it and generate a new one.

  ```coffeescript
    if count > 0
      groups = [ Arr.shuffle ( repos.map ({ name }) -> name ) ]
  ```

 Save the hash to our history so we can detect if we’re ever back in this state again.

 ```coffeescript
    ( history.push hash ) if hash?
 ```

 Next, we prepare to iterate through the groups, setting the index to 0. We initialize `succeeded` to be an empty set. We’ll add to that set as we build up successes.

```coffeescript
    index = 0
    succeeded = new Set
```

If we have a progress bar running from a previous run, stop it.

```coffeescript
    progress.stop() if progress?
```

If we’re running in `determined` mode—meaning, we keep trying until we’re sure we can’t make any progress—log the attempt.

```coffeescript
    if determined
      console.log "Attempt ##{ ++count }"
```

Star the progress bar, possibly for the first time.

```coffeescript
    progress = Progress.make count: repos.length
    progress.start()
```

Initialize the `mulligan`, which tells us whether we should re-run the same group when there are failures.

```coffeescript
    mulligan = true
```

We've now complete the initialization for the inner loop.

We run the inner loop until there are no more groups to run, or until we hit an empty group.

```coffeescript
    while (( group = groups[ index ])? && ( group.length > 0 ))
```

We initialize the failures array.

```coffeescript    
      failed = []
```

We place the promises for each task run into the `pending` array.

```coffeescript
      pending = 
        for repo in group
          do ( repo ) ->
```

We enqueue each task run using the `limiter` function, which limits the parallelization to the specifed batch size.

```coffeescript          
            limiter ->
              log.debug { repo, command }
```

Presuming the failure count for this repo is less than the number of allowable retries, run the task. Otherwise, log that we’ve encountered too many failures to run that task.

> [!Note]
>
> If we hit the too many failures case, there’s an argument that we should exit the inner loop, since there’s no way to make further progress. However, the idea here is to make as much progress as possible. Perhaps that should be based on the strategy: for some tasks, we probably want to exit as soon as possible.

If it succeeds—if it doesn't throw—add it to the `success` set. If it throws, log the error, remove it from the `success` set (in case it had succeeded in earlier run), and push it to the `failed` array.

> [!Note]
>
> We should probably use a Set for `failed` as well. The advantage of using a set over an array is that we don’t need to worry about cases where a failure might get added twice.

```coffeescript
              if failures[ repo ] <= retries
                try
                  result = await Script.run command, cwd: repo
                  log.debug { repo, result }
                  succeeded.add repo
                catch error
                  log.error
                    repo: repo
                    message: error.message
                    error: error
                  succeeded.delete repo
                  push failed, repo
              else
                log.error
                  repo: repo 
                  failures: failures[ repo ]
                  retries: retries
                  message: "Too many failures"
```

After we complete our attemt to run the task, update the progress bar.

```coffeescript
              progress.set succeeded.size
```

For each iteration of the inner loop, we await the completion of all the tasks.

```coffeescript
      await Promise.all pending
```

Now we have the results collected from the current iteration of the inner loop. We first handle the case where there are failures.

```coffeescript
      if ( failed.length > 0 )
```

If we have a mulligan (`mulligan` is true), we set it false (because we're about to use it) and continue. The idea here is that we're just going to try this group again, even though we had failures. This is useful when the failures aren't idempotent or there may be transient failures (due to say, network conditions).

```coffeescript
        if mulligan
          mulligan = false
```

If we don't have a mulligan, we prepare to move to the next group.

1. We reset the mulligan since we're moving to a new group.

2. We initialize an empty group if one doesn't exist. 

3. We “demote” the failures. 

If the group was empty, it will contain only the failures, which may result in successes this time, especially if we had some successes. If the group wasn't empty, we're simply adding the failures.

```coffeescript
        else
          mulligan = true
          groups[ ++index ] ?= []

          if groups[ index ]?
            for repo in failed
              log.debug {
                message: "demoting repo"
                repo
              }
              if ++failures[ repo ] > retries
                remove group, repo
                push groups[ index ], repo
```

In the case where there were no failures, we simply reset the mulligan, and move to the next group. If one doesn't exist, the inner `while` loop condition above will exit the loop.

```coffeescript

      else

        mulligan = true
        ++index
```

Back in the outer loop, we set our `done` flag based on the following:

1. We're not running in `determined` mode, in which case we're done because we only go through the loop once.

2. The success set contains all the target repos, which is the desired goal.

3. We've seen this state before (the failure has is in the history).

```coffeescript
    done = !determined ||
      (( succeeded.size == repos.length ) ||
        (( hash = Hash.array Array.from succeeded ) in history ))
```

Once we exit the outer loop, we stop the progress meter and log the failures and our success rate to the console.

```coffeescript
  progress.stop()

  for repo in repos when !( succeeded.has repo.name )
    log.error
      console:true
      repo: repo.name
      message: "failed"

  log.info 
    console: true
    message: "succeeded: #{ succeeded.size },
      failed: #{ repos.length - succeeded.size }"
````

