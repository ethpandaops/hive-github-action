# self-hosted-runner-dependencies

This directory contains a GitHub Action that installs dependencies for the self-hosted runner.
You don't need to use this action if you're using the public GitHub Actions runners.

## Usage

```yaml
jobs:
  run:
    runs-on: self-hosted
    steps:
      - uses: ethpandaops/hive-github-action/helpers/self-hosted-runner-dependencies@v0.2.0
        if: runner.environment != 'github-hosted'

```
