# Legion Go 2 internal IMU port (experimental)

Hardware behavior is UNCONFIRMED. No Legion Go 2 was available for this port.

## Provenance

- Upstream: https://github.com/ShadowBlip/InputPlumber, stable v0.81.0, commit
  ea60d873cca17edd1cb655ede26f557108135252, released 2026-09-14.
  Checked against upstream main and latest non-prerelease on 2026-10-03.
- Reference: https://github.com/razoomnik/legion-go-2-steamos-gyro at
  aab316924eb9ddd1497f1fa076dae6486ce471cf, including
  patches/inputplumber-legion-go-2.patch and 50-legion_go_2.yaml.
  Its recorded base is bb7424fd6fc097d123850950aaf1e6988f2093f3 (0.77.4).
- InputPlumber retains its GPL-3.0-or-later license, authors and LICENSE.
  The reference repository contains the GPLv3 license text. The mount matrix
  and body-IMU routing idea are adapted from razoomnik; no reference binaries
  or installer are redistributed. New files are provided under GPL-3.0-or-later.
- Changes and documentation were prepared with Codex and require human review.

## Decisions

The old patch was inspected rather than applied wholesale:

1. `iio.allow_internal_imu: true` opts the Go 2 accel_gyro_3d sources out of the
   hid_lenovo_go default motion filter. Other profiles and the BMI driver keep
   their original behavior. Runtime DBus filter changes remain possible.
2. gyro_3d and accel_3d remain attached, but active rather than `blocked: true`.
   This retains the source-lifetime principle of upstream 88c547a: IIO sources
   keep the composite alive while controllers disappear/re-enumerate. Actual
   preservation of virtual-device identity requires the suspend tests below.
3. Controller Center/Left/Right gyro and accelerometer events are excluded on
   gamepad HID interfaces. The body IMU is authoritative, including when
   controllers are detached; this is intentionally body motion, not detached
   controller motion. Buttons, axes, touchpad and rumble routes remain upstream.
4. Use deck + mouse + keyboard. Upstream 38050c8 already makes `deck` emulate
   Valve/SteamDeck IDs; the old product-ID patch is redundant. Deck routes the
   right touchpad itself, so an extra virtual touchpad is unnecessary.
5. Do NOT apply gain 50: upstream accel_gyro_3d already converts SI values to
   Deck raw units (916.7324722 LSB per rad/s; 1632.6530612 LSB per m/s²).
   Another x50 would over-amplify/clamp. Tests check 1 degree/s = 16 LSB and
   gravity = about 16000 LSB. Physical calibration remains unconfirmed.
6. Keep the reference mount matrix diag(1,-1,1) for both body sensors.
   Verify yaw/pitch/roll and gravity orientation physically.
7. Inherit 913f12c (Legion regressions), d3c21c9 and 7b69754 (touchpad/poll
   rates), f7fe555 and 50263d3 (macro release/missed event fixes). QuickAccess
   and Screenshot event handling remains upstream. Firmware-specific auxiliary
   buttons must be checked: `QuickAccess2`/`Keyboard` are not consumed by this
   deck target and may need a follow-up mapping after their desired behavior
   and actual reports are established. Do not claim all Legion keys work.

## Build

From the repository root, run `tools/legion-go2/build.sh` with Docker running.
The same command works on macOS using linux/amd64 emulation and Linux x86_64.
It validates the YAML/schema/routing, checks modified source formatting, runs
all Rust tests and builds `--locked --release --target x86_64-unknown-linux-gnu`.
Output: `dist/inputplumber-legion-go2-linux-x86_64.tar.gz` and its SHA-256
checksum. A tag matching `v*-legion-go2-gyro.*` publishes both files as an
experimental GitHub prerelease.

Compiler/base image digest, Cargo.lock and workflow actions are pinned. Debian
APT packages use the current Bookworm repositories: this is a reproducible
build procedure, not a claim of byte-for-byte deterministic output. Review
BUILD_LINKS.txt for runtime libraries; SteamOS must provide compatible libiio,
libudev and other linked libraries. Never install Debian libraries onto SteamOS.

The `Legion Go 2 Linux build` Actions workflow stores a test artifact on branch
pushes and publishes an experimental prerelease for matching tags. Fork
workflows may need to be enabled on GitHub's Actions page. No device
installation is performed by this project.
