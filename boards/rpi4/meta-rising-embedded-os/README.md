# meta-rising-embedded-os

Custom Yocto layer for Raspberry Pi 4 focused on a minimal, reproducible image with working Wi-Fi, DHCPv4, SSH, SFTP, and first-boot user provisioning.

## Layer Overview
Current image recipe:
- `recipes-risingembeddedmx/image/rising-embedded-os-image.bb`

Main capabilities implemented in this layer:
- Minimal networking stack (`wpa_supplicant`, `busybox-udhcpc`, `iproute2`, `iw`, `rfkill`)
- Automatic Wi-Fi + DHCPv4 on boot (`network-setup.service`)
- Default user provisioning at first boot (`default-user-setup.service`)
- SSH server via Dropbear (`ssh-server-dropbear`)
- SFTP backend via `openssh-sftp-server`
- Rootfs postprocess to expose `sbin` binaries from `bin`

## Directory Highlights
```
meta-rising-embedded-os/
├── conf/
│   ├── layer.conf
│   └── distro/
│       └── rising-embedded-os.conf
├── recipes-connectivity/
│   ├── network-setup/
│   │   ├── network-setup_1.0.bb
│   │   └── files/
│   │       ├── network-setup.sh
│   │       └── network-setup.service
│   └── wpa-supplicant/
│       ├── wpa-supplicant_%.bbappend
│       └── files/
│           └── wpa_supplicant.conf
├── recipes-core/
│   └── default-user/
│       ├── default-user_1.0.bb
│       └── files/
│           ├── default-user.conf
│           ├── default-user-setup.sh
│           └── default-user-setup.service
└── recipes-risingembeddedmx/
    └── image/
        └── rising-embedded-os-image.bb
```

## Build Workflow
Inside container:

```bash
cd /home/yocto/workspace
source boards/rpi4/poky/oe-init-build-env boards/rpi4/build-rpi4
bitbake rising-embedded-os-image
```

Output location:
- `boards/rpi4/build-rpi4/tmp/deploy/images/raspberrypi4-64/`

## Runtime Services
### 1. Auto Wi-Fi and DHCPv4
Provisioned by:
- `network-setup.service`

Check status:
```bash
systemctl status network-setup
journalctl -u network-setup -b --no-pager
```

### 2. SSH (Dropbear)
Dropbear is installed through:
- `IMAGE_FEATURES += " ssh-server-dropbear "`

Enable on running image (as root):
```bash
systemctl enable --now dropbear.socket
systemctl status dropbear.socket
```

Connect from host:
```bash
ssh <username>@<target-ip>
```

### 3. SFTP
SFTP is provided by:
- `openssh-sftp-server`

Test from host:
```bash
sftp <username>@<target-ip>
```

Verify on target:
```bash
which sftp-server
journalctl -u dropbear.socket -b --no-pager
```

### 4. Default User Provisioning
Provisioned by:
- `default-user-setup.service`
- config file: `/etc/default-user.conf`

Check status:
```bash
systemctl status default-user-setup
journalctl -u default-user-setup -b --no-pager
id <username>
```

Re-run for testing:
```bash
su
rm -rf /var/lib/default-user
systemctl start default-user-setup
```

## Credential Safety
Keep generic values in versioned config files and use local overrides.

Recommended for local-only credentials:
```bash
git update-index --skip-worktree boards/rpi4/meta-rising-embedded-os/recipes-core/default-user/files/default-user.conf
git update-index --skip-worktree boards/rpi4/meta-rising-embedded-os/recipes-connectivity/wpa-supplicant/files/wpa_supplicant.conf
```

To track them again:
```bash
git update-index --no-skip-worktree boards/rpi4/meta-rising-embedded-os/recipes-core/default-user/files/default-user.conf
git update-index --no-skip-worktree boards/rpi4/meta-rising-embedded-os/recipes-connectivity/wpa-supplicant/files/wpa_supplicant.conf
```

## Notes
- This layer currently targets a minimal system footprint.
- `ifconfig` is not included by default; use `ip` commands.
- Build and flash cycles are expected during service tuning.