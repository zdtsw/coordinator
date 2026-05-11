#!/bin/bash

# Clones llm-d-inference-scheduler at a pinned commit, builds the EPP image,
# and tags it as EPP_IMAGE (default: ghcr.io/llm-d/llm-d-inference-scheduler:dev).
#
# Usage:
#   ./scripts/build-epp-image.sh
#   EPP_IMAGE=my-registry/epp:custom ./scripts/build-epp-image.sh

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REPO_URL="https://github.com/llm-d/llm-d-inference-scheduler.git"
COMMIT="434575493d5bf3a5c7a5b9b1d6210ca6228ce076"

: "${EPP_IMAGE:?not set — run via 'make image-build-epp' or export EPP_IMAGE}"
: "${CONTAINER_RUNTIME:=$(command -v docker || command -v podman)}"
: "${CONTAINER_RUNTIME:?docker or podman not found}"

CLONE_DIR="$(mktemp -d)"
trap 'rm -rf "${CLONE_DIR}"' EXIT

echo "Cloning ${REPO_URL} ..."
git clone --no-tags --filter=blob:none "${REPO_URL}" "${CLONE_DIR}"

echo "Checking out ${COMMIT} ..."
git -C "${CLONE_DIR}" checkout "${COMMIT}"

echo "Building ${EPP_IMAGE} ..."
"${CONTAINER_RUNTIME}" build \
    --build-arg LDFLAGS="-s -w" \
    -t "${EPP_IMAGE}" \
    -f "${CLONE_DIR}/Dockerfile.epp" \
    "${CLONE_DIR}"

echo "Built ${EPP_IMAGE}"
