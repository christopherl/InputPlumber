# SteamOS trial and rollback

Experimental and hardware-unconfirmed. These commands are instructions only;
they have not been run on a Legion Go 2. Have a USB keyboard/mouse available.
Use the already installed SteamOS InputPlumber service, DBus policy, udev rules
and suspend helper. No root filesystem unlock or package replacement is needed.
If the stock package is much older, its policies/helpers may not be compatible
with 0.81.0: check first, and stop the trial if DBus/polkit/device access fails.

## Preflight

Download the Actions artifact or locally built archive, extract it and enter
`legion-go2`. Read PORT.md and HARDWARE-TEST.md. Check `sha256sum -c SHA256SUMS`,
`file inputplumber` (must be Linux x86-64) and `ldd ./inputplumber` (no missing
libraries; do not install Debian packages to satisfy SteamOS dependencies).
Check `/sys/class/dmi/id/product_name` is 83N0 or 83N1 and that
`/sys/bus/iio/devices/iio:device*/name` contains gyro_3d and accel_3d.
Record `systemctl cat inputplumber`, stock version and existing custom device
profiles. Stop other gyro installers/services that would launch another daemon.

The trial uses three NEW paths below. If any already exists, stop and back it
up, or remove a previous trial using its own rollback first. Do not overwrite
existing custom overrides. A prior matching config with an earlier filename
may take precedence; inspect `/etc/inputplumber/devices.d` before proceeding.

## Install trial overlay (manual)

Run from the extracted `legion-go2` directory:

```sh
# Must all be absent before creating the trial:
test ! -e /var/lib/inputplumber-go2-trial
test ! -e /etc/inputplumber/devices.d/49-legion_go_2_gyro_trial.yaml
test ! -e /etc/systemd/system/inputplumber.service.d/90-go2-gyro-trial.conf
# If ANY test fails, stop here.
sudo install -d -m 755 /var/lib/inputplumber-go2-trial
sudo install -m 755 inputplumber /var/lib/inputplumber-go2-trial/inputplumber
sudo install -d -m 755 /etc/inputplumber/devices.d
sudo install -m 644 50-legion_go_2.yaml /etc/inputplumber/devices.d/49-legion_go_2_gyro_trial.yaml
sudo install -d -m 755 /etc/systemd/system/inputplumber.service.d
sudo tee /etc/systemd/system/inputplumber.service.d/90-go2-gyro-trial.conf >/dev/null <<'UNIT'
[Service]
ExecStart=
ExecStart=/var/lib/inputplumber-go2-trial/inputplumber
UNIT
sudo systemctl daemon-reload
sudo systemctl restart inputplumber
systemctl status inputplumber --no-pager
journalctl -u inputplumber -b -n 100 --no-pager
```

The 49 filename precedes the stock 50 profile. The stock profile remains on
disk; confirm only one composite is created. The service retains its existing
hardening/DBus settings; the override only replaces the executable. Complete
the hardware plan before treating this as usable. Reboot only after startup,
controls, gyro and rollback have passed. SteamOS updates may alter package
interfaces: revalidate after updating.

## Rollback

The paths below are exclusively the new trial files, not stock package files.

```sh
sudo systemctl stop inputplumber
sudo rm /etc/systemd/system/inputplumber.service.d/90-go2-gyro-trial.conf
sudo rm /etc/inputplumber/devices.d/49-legion_go_2_gyro_trial.yaml
sudo systemctl daemon-reload
sudo systemctl start inputplumber
systemctl status inputplumber --no-pager
```

Confirm the service runs the original executable and the original controller
appears in Steam. Then delete the trial executable if desired:
`sudo rm /var/lib/inputplumber-go2-trial/inputplumber` followed by
`sudo rmdir /var/lib/inputplumber-go2-trial`. Keep original custom configuration
backups. If the stock service also fails, inspect the journal and restore the
previous gyro installer/service configuration rather than blindly reinstalling.
