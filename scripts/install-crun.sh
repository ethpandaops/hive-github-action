#!/usr/bin/env bash
# Install crun and make it the default runtime of the system Docker daemon.
#
# Hive connects to Docker through DOCKER_HOST or /var/run/docker.sock and
# ignores Docker contexts, so the runtime is configured in
# /etc/docker/daemon.json, the daemon restarted by the next step, rather than
# through setup-docker-action's daemon-config.
#
# Env: CRUN_VERSION (e.g. 1.30.1) and CRUN_SHA256_AMD64 / CRUN_SHA256_ARM64, the
# checksums of that version's static binaries. A missing checksum is an error.
set -euo pipefail

version="${CRUN_VERSION:?CRUN_VERSION is required}"
case "$(uname -m)" in
  x86_64) arch=amd64 ;;
  aarch64) arch=arm64 ;;
  *) echo "crun: unsupported architecture $(uname -m)" >&2; exit 1 ;;
esac
asset="crun-${version}-linux-${arch}"
base="https://github.com/containers/crun/releases/download/${version}"

case "${arch}" in
  amd64) sha256="${CRUN_SHA256_AMD64:-}" ;;
  arm64) sha256="${CRUN_SHA256_ARM64:-}" ;;
esac
if [ -z "${sha256}" ]; then
  echo "crun: no checksum given for ${asset}" >&2
  exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "${tmp}"' EXIT
curl -fsSL -o "${tmp}/crun" "${base}/${asset}"
echo "${sha256}  ${tmp}/crun" | sha256sum -c -
sudo install -m 0755 "${tmp}/crun" /usr/local/bin/crun
/usr/local/bin/crun --version

# Register crun and make it the default, keeping any existing settings.
command -v jq > /dev/null || { sudo apt-get update -q && sudo apt-get install -y -q jq; }
config=/etc/docker/daemon.json
current='{}'
if [ -s "${config}" ]; then
  current=$(sudo cat "${config}")
fi
sudo mkdir -p /etc/docker
echo "${current}" \
  | jq '.runtimes.crun.path = "/usr/local/bin/crun" | ."default-runtime" = "crun"' \
  | sudo tee "${config}" > /dev/null
echo "Docker daemon configuration (${config}):"
sudo cat "${config}"
