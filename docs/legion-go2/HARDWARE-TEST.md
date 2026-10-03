# Hardware acceptance plan

Status: all hardware cases UNTESTED. A successful build is not a device result.
Use a USB keyboard/mouse and keep rollback available before testing. Record
SteamOS version, kernel, firmware, original InputPlumber version, DMI product,
hid_lenovo_go state, sysfs IMU names, artifact checksum and source commit.

| Test | Procedure | Pass criterion |
|---|---|---|
| Startup | Restart service, inspect journal and Steam controller list | One virtual Steam controller, no competing gamepad, no IIO read errors |
| Internal IMU | With hid_lenovo_go loaded, rotate body around each axis; enable Steam gyro aiming | Motion reaches Steam on all axes, correct signs, no x50 saturation |
| Calibration | Hold level and stationary; turn body approx 90° at known pace | Gravity approx 1g; no unexpected roll/yaw swap, reasonable gyro magnitude; record drift |
| Detached controllers | Keep body still, rotate each detached controller; then rotate body | Controller movement does not drive gyro; body still does; controls keep working |
| Controls | ABXY, dpad, sticks, triggers, shoulders, paddles, M1/M2/M3/Y keys | One press/release each, correct mapping, no duplicate or stuck buttons |
| Legion/macros | Short/long/repeated guide, QuickAccess and screenshot-related inputs, 50 repetitions | Intended menu/action once per press; no stuck Steam/bumper; explicitly record unsupported auxiliary keys |
| Touchpad | Swipe, lift, tap, click, drag, corners, attached/detached/FPS mode | Smooth pointer, correct coordinates, no duplicate pointer or stuck touch |
| Rumble | Steam rumble test and one game, attached/detached | Both controllers respond and stop correctly, no I/O errors |
| Detach/reattach | XInput, DInput, wireless detached, FPS; repeat mode switches | Controllers recover; same virtual controller remains; output-only evdev still supplies rumble |
| Suspend/resume | In a running game, record composite path and USB identity; suspend/resume 10 times, also detached | Composite and virtual controller persist; game resumes input without restart; gyro/buttons/touchpad/rumble recover |
| Suspend held keys | Suspend with a button or pad contact held; release while asleep | No stuck key/touch/rumble after resume |
| Reboot/rollback | Cold reboot, then perform rollback | Trial starts correctly; stock controller behavior restored after rollback |

Inspect `journalctl -u inputplumber -b` after each lifecycle test. Read only
relevant device logs; remove personal identifiers before sharing. If sensor
sources disappear during suspend or Steam recreates the controller, mark the
continuity test FAILED and retain logs, rather than treating 88c547a as proof.
External SteamOS services may change targets or event filters over DBus; check
actual targets/filter state if the saved defaults do not appear at runtime.
