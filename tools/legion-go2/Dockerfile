# Rust compiler and Debian userspace pinned to the inspected image digest.
FROM rust:1.92-bookworm@sha256:e90e846de4124376164ddfbaab4b0774c7bdeef5e738866295e5a90a34a307a2
RUN apt-get update && apt-get install -y --no-install-recommends \
    libclang-dev libudev-dev libiio-dev libevdev-dev pkg-config python3 python3-yaml python3-jsonschema \
    && rm -rf /var/lib/apt/lists/*
RUN rustup component add rustfmt
WORKDIR /src
