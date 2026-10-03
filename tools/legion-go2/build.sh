#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
# Same linux/amd64 environment on macOS, Linux and Actions.
docker build --platform linux/amd64 -t inputplumber-go2-build -f tools/legion-go2/Dockerfile .
INPUTPLUMBER_SOURCE_COMMIT=$(git rev-parse HEAD)
docker run --rm --platform linux/amd64 \
  -e INPUTPLUMBER_SOURCE_COMMIT="$INPUTPLUMBER_SOURCE_COMMIT" \
  -v "$PWD:/src" -v inputplumber-go2-cargo:/usr/local/cargo/registry \
  inputplumber-go2-build bash tools/legion-go2/check-and-build.sh
