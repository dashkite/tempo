# Testing

This document outlines the testing approach and procedures for the Tempo repository.

## What is the testing strategy for Tempo?

Tempo utilizes a suite of tests to verify the correctness of its metarepo management logic and CLI command handling. The tests focus on ensuring that repositories are correctly added, removed, and synchronized, and that commands can be reliably broadcasted across the metarepo.

## How to execute tests?

The developer can execute the test suite using the standard task runner command.

```bash
npx genie test
```

This command invokes the test runner and processes all test cases located within the `test/` directory.

If the `npx genie test` command fails or is unavailable, the developer MAY use the fallback script:
```bash
./scripts/test
```
