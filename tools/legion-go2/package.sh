#!/usr/bin/env bash
set -euo pipefail
: "${INPUTPLUMBER_SOURCE_COMMIT:?Pass the host checkout commit to the container}"
mkdir -p dist/legion-go2
cp target/x86_64-unknown-linux-gnu/release/inputplumber dist/legion-go2/
cp rootfs/usr/share/inputplumber/devices/50-legion_go_2.yaml dist/legion-go2/
cp LICENSE docs/legion-go2/*.md dist/legion-go2/
printf '%s\n' "$INPUTPLUMBER_SOURCE_COMMIT" > dist/legion-go2/SOURCE_COMMIT
rustc --version > dist/legion-go2/BUILD_COMPILER
ldd target/x86_64-unknown-linux-gnu/release/inputplumber > dist/legion-go2/BUILD_LINKS.txt
(cd dist/legion-go2 && sha256sum inputplumber 50-legion_go_2.yaml > SHA256SUMS)
tar -C dist -czf dist/inputplumber-legion-go2-linux-x86_64.tar.gz legion-go2
(
  cd dist
  sha256sum inputplumber-legion-go2-linux-x86_64.tar.gz > \
    inputplumber-legion-go2-linux-x86_64.tar.gz.sha256
)
