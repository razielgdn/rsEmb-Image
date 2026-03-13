# Yocto Project: Multi-Board Embedded Linux Builder

## Introduction
This repository documents the complete process of implementing the **Yocto Project** to build custom Linux images for embedded boards. It demonstrates production-ready workflows using Docker containerization and multi-board support.

## Overview
This project creates custom Linux images for multiple embedded boards using the **Yocto Project** (Scarthgap version). It showcases best practices for:
- Containerized Yocto builds with persistent caching
- Multi-board architecture (Raspberry Pi 4 and Libre Computer boards)
- Custom layer development with minimal and reproducible images
- Reproducible builds across development environments

## Objectives
- Create stable, production-ready images for Raspberry Pi 4 and Libre Computer boards
- Master embedded Linux fundamentals through practical implementation
- Develop reusable build automation and documentation
- Share knowledge and best practices with the embedded Linux community

## Project Structure
```
raspberry-yocto/
├── Dockerfile                      # Yocto builder container (Debian 12 + BitBake 2.16)
├── docker-compose.yml              # Container orchestration with volume persistence
├── build-project.sh                # Automated build script (board selection, env setup)
├── Readme.md                       # This file
├── Project-log.md                  # Development timeline and decisions
│
├── boards/
│   ├── rpi4/                       # Raspberry Pi 4 board configuration
│   │   ├── poky/                   # Yocto core (git submodule)
│   │   │   ├── meta/               # OE-Core base layer
│   │   │   ├── meta-poky/          # Poky distribution layer
│   │   │   ├── meta-yocto-bsp/     # Reference BSP layer
│   │   │   └── oe-init-build-env   # Environment setup script
│   │   ├── meta-openembedded/      # Additional recipes (git submodule)
│   │   │   ├── meta-oe/            # General utilities
│   │   │   ├── meta-python/        # Python recipes
│   │   │   ├── meta-networking/    # Network tools
│   │   │   ├── meta-multimedia/    # Multimedia support
│   │   │   └── meta-filesystems/   # Filesystem utilities
│   │   ├── meta-raspberrypi/       # RPi BSP layer (git submodule)
│   │   │   ├── recipes-kernel/     # Kernel recipes and patches
│   │   │   ├── recipes-bsp/        # Bootloader and firmware
│   │   │   └── conf/machine/       # Machine definitions
│   │   ├── meta-rising-embedded-os/ # Custom layer (git submodule)
│   │   │   ├── conf/               # Layer configuration
│   │   │   ├── recipes-bsp/        # Custom BSP recipes
│   │   │   ├── recipes-kernel/     # Kernel customizations
│   │   │   └── recipes-risingembeddedmx/ # Custom image recipes
│   │   ├── conf/                   # Build configuration templates
│   │   │   ├── local-minimal.conf  # Minimal image config
│   │   │   ├── local-rising-embedded-os.conf # Full-featured config
│   │   │   ├── bblayers-minimal.conf # Minimal layer setup
│   │   │   └── bblayers-rising-embedded-os.conf # Full layer stack
│   │   ├── build-rpi4/             # Build output directory (git-ignored)
│   │   │   ├── conf/               # Active build configuration
│   │   │   │   ├── local.conf      # Machine, parallelism, features
│   │   │   │   └── bblayers.conf   # Layer ordering and paths
│   │   │   ├── tmp/                # Temporary build artifacts
│   │   │   │   ├── deploy/images/  # Final images (*.wic, *.ext4)
│   │   │   │   ├── work/           # Per-recipe build directories
│   │   │   │   └── sysroots/       # Cross-compilation roots
│   │   │   └── cache/              # BitBake metadata cache
│   │   └── Readme-Rpi-4.md         # Board-specific documentation
│   │
│   └── aml-s905x-cc/               # Libre Computer board configuration
│       ├── conf/                   # Board-specific config
│       │   └── bblayers.conf       # Layer configuration for AML board
│       └── README.md               # Board-specific documentation
│
└── Docker Volumes (persistent):
    ├── yocto-downloads/            # Shared source downloads (~10-20GB)
    ├── yocto-sstate/               # Shared state cache (~20-50GB, speeds rebuilds)
    └── yocto-build/                # Build artifacts (optional persistence)
```

## Download the Project
Clone the repository with all submodules:

```bash
git clone --recursive https://github.com/razielgdn/rsEmb-Image.git
cd rsEmb-Image
```

If you've already cloned without `--recursive`, initialize submodules:
```bash
git submodule update --init --recursive
```

## Quick Start

### 1. Build and Start the Container
```bash
docker compose up -d --build
```

### 2. Access the Build Environment
```bash
docker compose exec yocto bash
```

### 3. Build an Image
Use the automated build script:
```bash
chmod +x build-project.sh
./build-project.sh -h  # Show help and available options
./build-project.sh -v  # Build with verbose output
```

Or manually source the environment and build:
```bash
# For Raspberry Pi 4
source boards/rpi4/poky/oe-init-build-env boards/rpi4/build-rpi4
bitbake core-image-minimal  # or your custom image
```

### 4. Find the Built Image
Built images are located at:
- **RPi4**: `/home/yocto/tmp/deploy/images/raspberrypi4-64/`
- **Final flash image (.rpi-sdimg)**: `/output/rpi4-image-to-flash.rpi-sdimg`
- **Libre Computer**: `boards/aml` Temptatively, the AML board is still in development, so the exact path may vary.

## Container Management

### Container Lifecycle
- **Build and start**:   
  ```bash
  docker compose up -d --build
  ```

- **Access build environment**:   
  ```bash    
  docker compose exec yocto bash
  ```  

- **Stop container**:   
  ```bash 
  docker compose down
  ```

- **Rebuild from scratch** (when Dockerfile changes):
  ```bash
  docker compose build --no-cache
  docker compose up -d
  ```

### Container Features
- **Persistent volumes**: Downloads, sstate cache, and build artifacts survive container restarts
- **Resource allocation**: Configure CPU/memory limits in docker-compose.yml
- **Working directory**: `/home/yocto/workspace` (mounted from repository root)
- **User**: Non-root user `yocto` (UID matches host for file permissions)

## Supported Boards

### Raspberry Pi 4
- **Machine**: `raspberrypi4-64`
- **Architecture**: ARM 64-bit (aarch64)
- **Features**: WiFi, GPIO, dual HDMI output, USB boot support
- **Documentation**: [Readme-Rpi-4.md](boards/rpi4/Readme-Rpi-4.md)
- **Status**: 
  - [x] Minimal image with basic functionality
  - [x] Custom image (`rising-embedded-os-image`) successfully built.
  - [x] Hardware testing completed on Raspberry Pi 4 (Wi-Fi + DHCPv4 working).
  
### Libre Computer Le Potato (AML-S905X-CC)  in development
- **Machine**: 🔧 In development
- **Architecture**: 🔧 In development
- **Features**: 🔧 In development
- **Documentation**: 🔧 In development
- **Status**: 🔧 In development

## Custom Layer: meta-rising-embedded-os

The **meta-rising-embedded-os** layer provides a minimal embedded Linux image focused on connectivity and reproducible startup behavior.

### Included Features
- **Remote Access**: Dropbear SSH server (lightweight alternative to OpenSSH)
- **Wi-Fi Support**: `wpa_supplicant` + `wpa_cli`
- **DHCPv4 Client**: `busybox-udhcpc`
- **Boot Automation**: `network-setup.service` for automatic Wi-Fi association and DHCP at boot
- **Network Utilities**: `iproute2`, `iw`, `rfkill`

### Automatic Wi-Fi at Boot
The image includes a custom recipe:
- `boards/rpi4/meta-rising-embedded-os/recipes-connectivity/network-setup/network-setup_1.0.bb`

Installed artifacts:
- `/usr/bin/network-setup.sh`
- `network-setup.service` (enabled by default)

This service runs at startup and performs:
1. `rfkill unblock wifi`
2. `wpa_supplicant` startup using `/etc/wpa_supplicant.conf`
3. DHCP request via `udhcpc`

To check status on target:
```bash
systemctl status network-setup
journalctl -u network-setup -b --no-pager
```

### Configuration Templates
Located in `boards/rpi4/conf/`:
- **Minimal build**:
  - `local-minimal.conf`: Basic system, minimal packages
  - `bblayers-minimal.conf`: Core layers only
- **Full-featured build**:
  - `local-rising-embedded-os.conf`: All features enabled
  - `bblayers-rising-embedded-os.conf`: Complete layer stack

## Build Automation: build-project.sh
The automated build script handles environment setup and board selection:

### Usage
```bash
chmod +x build-project.sh
./build-project.sh -h  # Display help and available options
./build-project.sh -v  # Build with verbose output
./build-project.sh -b rpi4  # Build for specific board
```

### Features
- Automatic environment initialization
- Board-specific configuration selection
- Pre-build dependency checks
- Verbose logging option

## Documentation

### Board-Specific Guides
- **Raspberry Pi 4**: [Readme-Rpi-4.md](boards/rpi4/Readme-Rpi-4.md)
  - Flashing images to SD cards
  - WiFi and network configuration
  - GPIO and hardware interfaces
  - Troubleshooting common issues

### Development Log
- **Project Timeline**: [Project-log.md](Project-log.md)
  - Daily development progress
  - Technical decisions and rationale
  - Challenges encountered and solutions
  - Lessons learned

### Blog Articles
Detailed tutorials, tips & tricks, and deep-dives:
- [Rising Embedded MX Blog](https://razielgdn.github.io/risingembeddedmx/projects/en/yocto/intro/build-raspberrypi)
- Topics covered: Yocto basics, layer development, BSP customization, troubleshooting

## Useful Commands

### Docker Management
- **Check running containers**:   
  ```bash
  docker ps
  docker stats yocto-dev  # Monitor resource usage
  ```

- **Inspect images**:
  ```bash
  docker images
  docker image inspect yocto-builder:latest
  ```

- **Manage volumes**:
  ```bash
  docker volume ls
  docker volume inspect yocto-downloads  # Check volume details
  ```

### BitBake Commands (Inside Container)
- **Build an image**:
  ```bash
  bitbake core-image-minimal           # Minimal bootable image
  bitbake rising-embedded-os-image     # Custom image from meta-rising-embedded-os
  ```

- **Clean builds**:
  ```bash
  bitbake -c clean <recipe>            # Clean specific recipe
  bitbake -c cleanall <recipe>         # Remove all artifacts including downloads
  ```

- **Dependency analysis**:
  ```bash
  bitbake -g <image>                   # Generate dependency graphs
  bitbake -e <recipe> | grep ^VARIABLE # Inspect variable values
  ```

- **Prefetch sources** (recommended before first build):
  ```bash
  bitbake --runall fetch core-image-minimal
  ```

### Host System Monitoring
- **Resource usage**:
  ```bash
  htop                                 # Interactive process viewer
  df -h                                # Check disk space
  free -h                              # Check memory usage
  ```

## Development Workflow

### Typical Build Cycle
1. **Start container**: `docker compose up -d`
2. **Enter environment**: `docker compose exec yocto bash`
3. **Source build environment**: `source boards/rpi4/poky/oe-init-build-env boards/rpi4/build-rpi4`
4. **Modify recipes** in custom layers as needed
5. **Run build**: `bitbake <image-name>`
6. **Test image** on target hardware
7. **Iterate**: Modify → Build → Test

### Layer Development
- Custom recipes go in `boards/rpi4/meta-rising-embedded-os/`
- Follow Yocto naming conventions: `<name>_<version>.bb`
- Test with `bitbake -c compile <recipe>` before full image build

## Troubleshooting

### Common Issues
- **Fetch failures**: Check network connectivity, verify download mirrors
- **Parse errors**: Validate recipe syntax with `bitbake-layers show-recipes`
- **Builds**: Increase `BB_NUM_THREADS` and `PARALLEL_MAKE` in local.conf or decrease if running out of memory
- **Permission issues**: Ensure Docker volumes have correct ownership and permissions
- **Container crashes**: Monitor resource usage, adjust limits in docker-compose.yml

### Getting Help
- Check [Project-log.md](Project-log.md) for similar issues and solutions
- Review Yocto documentation: https://docs.yoctoproject.org/
- Ask to Gemini, Github Copilot Chat, or other AI assistants for quick troubleshooting tips.
  
## License
This project follows the licensing of its components:
- Yocto/Poky: Mix of GPL-2.0 and MIT licenses
- Custom layers: Check individual layer LICENSE files
- Build scripts and documentation: MIT License (see repository)

## Acknowledgments

- **Yocto Project**: https://www.yoctoproject.org/
- **OpenEmbedded**: https://www.openembedded.org/
- **Raspberry Pi Foundation**: https://www.raspberrypi.org/
- **Libre Computer**: https://libre.computer/

---

**Author**: [Rising Embedded MX](https://razielgdn.github.io/risingembeddedmx/about/about-en)  
**Repository**: [rsEmb-Image](https://github.com/razielgdn/rsEmb-Image)
  
