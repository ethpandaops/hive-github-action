# Ethereum Hive Github Action

This action is a wrapper around [Ethereum Hive](https://github.com/ethereum/hive). It allows you to run tests with different clients and simulators. It also supports uploading test results to S3 and/or as a workflow artifact.

## Inputs

### Test Configuration

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `simulator` | Simulator to run (e.g. ethereum/sync) | Yes | `ethereum/sync` |
| `client` | Client to test | Yes | `go-ethereum` |
| `client_config` | Client configuration in YAML format | No | - |
| `extra_flags` | Additional flags to pass to hive | No | - |

### Hive Configuration

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `hive_repository` | Hive repository to use | No | `ethereum/hive` |
| `hive_version` | Hive version/branch to use | No | `master` |
| `go_version` | Go version used to build hive | No | `1.21` |

### S3 Upload Configuration

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `s3_upload` | Upload test results to S3 | No | `false` |
| `s3_bucket` | S3 bucket name | No* | - |
| `s3_path` | Path prefix in S3 bucket | No | `hive-results` |
| `rclone_version` | Rclone version to use | No | `latest` |
| `rclone_config` | Base64 encoded rclone config file | No | - |

*Required if `s3_upload` is `true`

### GitHub Workflow Artifact Configuration

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `workflow_artifact_upload` | Upload test results as a workflow artifact | No | `false` |
| `workflow_artifact_prefix` | Name of the workflow prefix. If not provided, the prefix will be the simulator and client name. | No | - |

## Examples

### Simple example doing sync tests with the latest go-ethereum

```yaml
- uses: ./.github/actions/hive
  with:
    client: go-ethereum
    simulator: ethereum/sync
```

### With custom client config

You can customize the [client configuration](https://github.com/ethereum/hive/blob/master/docs/commandline.md#client-build-parameters). This allows using different docker files that are available for each client and their respective build arguments.

```yaml
env:
  CLIENT_CONFIG: |
    - client: go-ethereum
      nametag: prague-devnet-5
      dockerfile: git
      build_args:
        github: ethpandaops/go-ethereum
        tag: my-custom-branch
```

Then you can use the `CLIENT_CONFIG` environment variable in your workflow.

```yaml
- uses: ./.github/actions/hive
  with:
    client: go-ethereum
    simulator: ethereum/sync
    client_config: ${{ env.CLIENT_CONFIG }}
```

### Uploading the results directory to S3

You'll need to create an rclone config and base64 encode it. Then store it as a github actions secret on your repository.

An example rclone config could look like this:

```toml
# Content of rclone.conf
[s3]
type = s3
provider = Cloudflare
region = auto
endpoint = https://your-r2-account-id.r2.cloudflarestorage.com
access_key_id = your-access-key-id
secret_access_key = your-secret-access-key
no_check_bucket = true
```

Then you can run `base64 -w 0 rclone.conf` and store the output as a github actions secret.

Afterwards you just need to reference the secret for the `rclone_config` input.

```yaml
- uses: ./.github/actions/hive
  with:
    client: go-ethereum
    simulator: ethereum/sync
    client_config: ${{ env.CLIENT_CONFIG }}
    s3_upload: true
    s3_bucket: my-bucket
    s3_path: my-path
    rclone_config: ${{ secrets.RCLONE_CONFIG }}
```

### Uploading the results directory as an GitHub workflow artifact

This will upload the test results as a workflow artifact. By default the artifact prefix will be the simulator and client name. You can override this by providing a `workflow_artifact_prefix` input.
```yaml
- uses: ./.github/actions/hive
  with:
    client: go-ethereum
    simulator: ethereum/sync
    workflow_artifact_upload: true
    # workflow_artifact_prefix: my-custom-prefix
```

## License

Refer to the repository's license file for information on the licensing of this GitHub Action and the associated software.
