#!/usr/bin/env bash
set -euo pipefail
python3 tools/legion-go2/validate-profile.py
rustfmt --edition 2021 --check src/input/source/iio/accel_gyro_3d.rs
cargo test --locked
cargo build --locked --release --target x86_64-unknown-linux-gnu
bash tools/legion-go2/package.sh
