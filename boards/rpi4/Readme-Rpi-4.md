# Raspberry Pi 4 - Yocto Build Configuration

## Overview
This directory contains all the Yocto/BitBake configuration and layers needed to build custom Linux images for the **Raspberry Pi 4** (64-bit). The project supports both minimal console-only images and a custom **Rising Embedded OS** distribution with additional features.

## Current Status
✅ **Completed:**
- Docker containerized build environment with persistent volumes
- Multi-layer architecture (Poky, meta-openembedded, meta-raspberrypi, meta-rising-embedded-os)
- Automated build script (`build-project.sh`) with multiple profiles
- Successful image compilation (core-image-minimal and rising-embedded-os-image)
- Resource-optimized container configuration (12GB RAM, 10 threads)

⏳ **In Progress:**
- Physical board testing (image compiled but not yet deployed to hardware)
- Documentation of custom layer recipes and bbappends

🔜 **Planned:**
- GUI-enabled image variants
- Additional custom recipes and system configurations
- Complete testing on Raspberry Pi 4 hardware

## Supported Build Profiles

### 1. Minimal Profile
- **Image:** `core-image-minimal`
- **Description:** Minimal bootable console image (~200MB)
- **Use Case:** Testing, development base, resource-constrained applications
- **Config Files:** 
  - [conf/local-minimal.conf](conf/local-minimal.conf)
  - [conf/bblayers-minimal.conf](conf/bblayers-minimal.conf)

### 2. Rising Embedded OS Profile (Default)
- **Image:** `rising-embedded-os-image`
- **Description:** Custom distribution based on `core-image-base` with:
  - Network services (NFS server, NetworkManager, SSH/Dropbear)
  - WiFi/Bluetooth firmware (BCM43455)
  - Development tools (nano, vim)
  - SystemD integration
- **Use Case:** Production-ready embedded Linux system
- **Config Files:** 
  - [conf/local-rising-embedded-os.conf](conf/local-rising-embedded-os.conf)
  - [conf/bblayers-rising-embedded-os.conf](conf/bblayers-rising-embedded-os.conf)

## Quick Start (Docker Container)

### Prerequisites
- Docker and Docker Compose installed
- At least **50GB free disk space** (for sstate cache and build artifacts)
- Recommended hardware: **16GB RAM**, **6+ CPU cores**

### 1. Start the Build Environment
From the repository root:
```bash
# Build and start the container
docker compose up -d --build

# Access the build environment
docker compose exec yocto bash
```

### 2. Automated Build (Recommended)
Use the provided build script:
```bash
# Build Rising Embedded OS (default profile)
./build-project.sh

# Build minimal image
./build-project.sh minimal

# Build with verbose output
./build-project.sh -v

# Show all available options
./build-project.sh -h
```

### 3. Manual Build Process
For more control over the build process:

```bash
# Navigate to the RPi4 directory
cd /home/yocto/workspace/boards/rpi4

# Source the Yocto environment
source poky/oe-init-build-env build-rpi4

# Copy configuration files (first time only)
cp ../conf/local-rising-embedded-os.conf conf/local.conf
cp ../conf/bblayers-rising-embedded-os.conf conf/bblayers.conf

# Optional: Pre-fetch all sources (recommended for first build)
bitbake --runall fetch rising-embedded-os-image

# Build the image (this will take 2-6 hours on first build)
bitbake rising-embedded-os-image
```
## Layer Architecture

The RPi4 build uses the following layers (order matters for recipe precedence):

1. **poky/meta** - OpenEmbedded Core layer
2. **poky/meta-poky** - Poky distribution layer
3. **poky/meta-yocto-bsp** - Reference BSP layer
4. **meta-openembedded/meta-oe** - Extended recipes
5. **meta-openembedded/meta-python** - Python packages
6. **meta-openembedded/meta-networking** - Network utilities
7. **meta-openembedded/meta-multimedia** - Multimedia support
8. **meta-raspberrypi** - Raspberry Pi BSP layer (kernel, bootloader, firmware)
9. **meta-rising-embedded-os** - Custom distribution layer

### Key Layer Locations
```
boards/rpi4/
├── poky/                      # Yocto core (git submodule - Scarthgap)
├── meta-openembedded/         # Additional recipes (git submodule)
├── meta-raspberrypi/          # RPi BSP (git submodule)
└── meta-rising-embedded-os/   # Custom layer (git submodule)
```

## Output Artifacts

### Build Output Location
Images are generated in the container at:
```
/home/yocto/tmp/deploy/images/raspberrypi4-64/
```

This maps to the Docker volume `yocto-tmp` for persistence across container restarts.

### Generated Files
- **rising-embedded-os-image-raspberrypi4-64.rpi-sdimg** - SD card image (ready to flash)
- **rising-embedded-os-image-raspberrypi4-64.manifest** - Package manifest
- **bcm2711-rpi-4-b.dtb** - Device tree blob
- **Image** - Linux kernel image
- **modules-*.tgz** - Kernel modules

### Copying Image to Host
Since the output is in a Docker volume, copy it to the workspace:
```bash
# Inside the container
cp /home/yocto/tmp/deploy/images/raspberrypi4-64/*.rpi-sdimg \
   /home/yocto/workspace/boards/rpi4/rpi4-image-to-flash.sdimg
```

Now it's accessible from your host at:
```
boards/rpi4/rpi4-image-to-flash.sdimg
```

## Flashing the Image

### On Linux
```bash
# Find your SD card device (e.g., /dev/sdb, /dev/mmcblk0)
lsblk

# Flash the image (replace /dev/sdX with your SD card)
sudo dd if=rpi4-image-to-flash.sdimg of=/dev/sdX bs=4M status=progress
sync
```

### On Windows
Use [balenaEtcher](https://etcher.balena.io/) or [Rufus](https://rufus.ie/) to flash the `.sdimg` file to an SD card.

## Configuration Details

### Machine Settings
- **MACHINE:** `raspberrypi4-64` (64-bit ARM)
- **Architecture:** aarch64
- **Kernel:** Linux kernel from meta-raspberrypi layer
- **Bootloader:** U-Boot (configured by meta-raspberrypi)


## Troubleshooting

### Build Failures

#### Package Compilation Errors
Some packages may fail on the first attempt due to network issues or race conditions:

```bash
# Common packages that may need manual intervention:
# - gcc-cross-aarch64
# - cmake-native
# - curl-native
# - gnutls
# - libsolv-native

# Fix approach 1: Retry with continue-on-error flag
bitbake -k <package-name>

# Fix approach 2: Clean and rebuild specific package
bitbake -c cleansstate <package-name>
bitbake <package-name>

# Fix approach 3: Remove work directory and rebuild
rm -rf /home/yocto/tmp/work/x86_64-linux/<package-name>/*
bitbake <package-name>
```

### Testing Configuration Changes
```bash
# List all available packages
bitbake -s

# Show recipe dependencies
bitbake -g <recipe-name>

# Show recipe information
bitbake-layers show-recipes <recipe-name>

# Validate layer configuration
bitbake-layers show-layers
```



