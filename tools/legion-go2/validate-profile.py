"""Check routing invariants which protect gyro and suspend continuity."""
import json
from pathlib import Path
import yaml
import jsonschema
root = Path(__file__).resolve().parents[2]
profile = yaml.safe_load((root / 'rootfs/usr/share/inputplumber/devices/50-legion_go_2.yaml').read_text())
schema = json.loads((root / 'rootfs/usr/share/inputplumber/schema/composite_device_v1.json').read_text())
jsonschema.validate(profile, schema)
assert profile['target_devices'] == ['deck', 'mouse', 'keyboard']
imus = [s for s in profile['source_devices'] if 'iio' in s]
assert {s['iio']['name'] for s in imus} == {'gyro_3d', 'accel_3d'}
for source in imus:
    assert not source.get('blocked', False), 'IMU must remain active and anchor composite lifecycle'
    assert source['iio']['allow_internal_imu'] is True
    assert source['iio']['mount_matrix'] == {'x': [1, 0, 0], 'y': [0, -1, 0], 'z': [0, 0, 1]}
for source in profile['source_devices']:
    if 'hidraw' in source and source['hidraw']['interface_num'] in (0, 2):
        assert set(source['events']['exclude']) == {f'{kind}:{position}' for kind in ('Gyroscope', 'Accelerometer') for position in ('Left', 'Right', 'Center')}
# Touchpad HID sources and rumble output-only evdev remain from upstream.
assert len([s for s in profile['source_devices'] if s.get('hidraw', {}).get('interface_num') == 1]) == 4
assert any(s.get('events', {}).get('exclude') == ['*'] and not s.get('blocked', False) for s in profile['source_devices'] if 'evdev' in s)
print('Go 2 profile schema and routing checks passed')
