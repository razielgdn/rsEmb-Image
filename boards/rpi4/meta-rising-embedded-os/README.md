# Copilot Instructions: Raspberry Pi Yocto Build Project

## Project Overview
This is a **Yocto/BitBake embedded Linux image builder** for Raspberry Pi 4 and Libre Computer boards. The project uses Docker for containerization and git submodules to manage Yocto layers (Poky, meta-openembedded, board-specific BSP layers).


## Custom Distro Layer Integration (meta-risingembeddedmx)

### Layer Structure
The `meta-risingembeddedmx` custom layer provides:
- **Custom Distro**: `risingembeddedmx.conf` - Defines distro policies, package selections, and build behaviors
- **Custom Image Recipe**: `risingembeddedmx-image.bb` - Full-featured image with additional packages
- **Kernel Modules**: Custom kernel module recipes for hardware-specific functionality
- **Custom Applications**: Application recipes (examples: hello-world, system utilities)
- **BSP Customization**: Board-specific bootfiles, device tree overlays, etc.

### Directory Structure
```
boards/rpi4/meta-risingembeddedmx/
├── conf/
│   ├── layer.conf                          # Layer metadata & compatibility
│   └── distro/
│       └── risingembeddedmx.conf          # Custom distro configuration
├── recipes-kernel/
│   ├── kconf/
│   │   ├── linux-raspberrypi%.bbappend    # Kernel config modifications
│   │   └── files/
│   │       └── fragment.cfg                # Kernel defconfig fragment
│   └── test-module/
│       ├── re-test-module_1.0.bb          # Custom kernel module
│       └── files/
│           ├── Makefile
│           └── testmodule.c
├── recipes-risingembeddedmx/
│   ├── custom-application/
│   │   ├── re-custom-application_1.0.bb   # Custom app recipe
│   │   └── files/
│   │       ├── hello.c
│   │       └── Makefile
│   └── image/
│       └── risingembeddedmx-image.bb      # Full custom image
├── recipes-bsp/
│   └── bootfiles/
│       └── bcm2835-bootfiles.bbappend     # RPi bootloader customization
└── README.md                               # Layer documentation
```

### Layer Registration

**1. Add to `bblayers.conf`** (after BSP layers, before distro selection):
```bash
# filepath: boards/rpi4/conf/bblayers.conf
BBLAYERS ?= " \
  /home/yocto/workspace/boards/rpi4/poky/meta \
  /home/yocto/workspace/boards/rpi4/poky/meta-poky \
  /home/yocto/workspace/boards/rpi4/poky/meta-yocto-bsp \
  /home/yocto/workspace/boards/rpi4/meta-openembedded/meta-oe \
  /home/yocto/workspace/boards/rpi4/meta-openembedded/meta-python \
  /home/yocto/workspace/boards/rpi4/meta-raspberrypi \
  /home/yocto/workspace/boards/rpi4/meta-risingembeddedmx \
  "
```

**2. Select distro in `local.conf`**:
```bash
# filepath: boards/rpi4/conf/local.conf
# Custom distro selection
DISTRO = "risingembeddedmx"
```

### Building with Custom Distro

```bash
# Inside container
cd /home/yocto/workspace
source boards/rpi4/poky/oe-init-build-env boards/rpi4/build-rpi4

# Fetch sources
bitbake --runall fetch risingembeddedmx-image

# Build custom image
bitbake risingembeddedmx-image
```

**Output location**: `boards/rpi4/build-rpi4/tmp/deploy/images/raspberrypi4-64/`

### Layer Configuration (layer.conf)

```
# filepath: boards/rpi4/meta-risingembeddedmx/conf/layer.conf
BBPATH .= ":${LAYERDIR}"

BBFILES += "${LAYERDIR}/recipes-*/*/*.bb"
BBFILES += "${LAYERDIR}/recipes-*/*/*.bbappend"

BBFILE_COLLECTIONS += "risingembeddedmx"
BBFILE_PATTERN_risingembeddedmx = "^${LAYERDIR}/"
BBFILE_PRIORITY_risingembeddedmx = "10"

LAYERDEPENDS_risingembeddedmx = "core openembedded-layer raspberrypi"
LAYERSERIES_COMPAT_risingembeddedmx = "scarthgap nanbield mickledore langdale kirkstone honister gatesgarth dunfell"
```

### Distro Configuration (risingembeddedmx.conf)

```
# filepath: boards/rpi4/meta-risingembeddedmx/conf/distro/risingembeddedmx.conf
require conf/distro/poky.conf

DISTRO = "risingembeddedmx"
DISTRO_NAME = "Rising Embedded MX"
DISTRO_VERSION = "1.0"
MAINTAINER = "Your Name <email@example.com>"

# Inherit from Poky and extend
DISTRO_FEATURES_append = " systemd"
IMAGE_FEATURES_append = " ssh-server-openssh"

# Package management preferences
PREFERRED_PROVIDER_virtual/kernel = "linux-raspberrypi"
PREFERRED_VERSION_linux-raspberrypi = "6.1%"

# Custom distro policies
TCLIBCVERSION = "12.3"
```

### Custom Image Recipe (risingembeddedmx-image.bb)

```
# filepath: boards/rpi4/meta-risingembeddedmx/recipes-risingembeddedmx/image/risingembeddedmx-image.bb
require recipes-core/images/core-image-minimal.bb

DESCRIPTION = "Rising Embedded MX - Custom distribution for Raspberry Pi"
IMAGE_FEATURES += " ssh-server-openssh dev-pkgs"

IMAGE_INSTALL += " \
    re-custom-application \
    re-test-module \
    vim \
    htop \
    git \
    curl \
    "
```

## Critical Developer Workflows

### Container Setup & Build
```bash
# Start container
docker compose up -d

# Initialize build for a board (inside container)
./init-environment.sh rpi4           # Sources oe-init-build-env
source boards/rpi4/poky/oe-init-build-env ../build-rpi4

# Pre-fetch sources (optional but recommended for first build)
bitbake --runall fetch risingembeddedmx-image

# Build the custom image
bitbake risingembeddedmx-image
```

**Key convention**: Build happens from `boards/{board}/build-{board}/`, not workspace root.

### Output Artifacts
- **RPi4 (Custom)**: `/boards/rpi4/build-rpi4/tmp/deploy/images/raspberrypi4-64/risingembeddedmx-image-*.rootfs.*`
- **RPi4 (Minimal)**: `/boards/rpi4/build-rpi4/tmp/deploy/images/raspberrypi4-64/core-image-minimal-*.rootfs.*`

## Project-Specific Conventions

### Configuration Management
- **`local.conf`**: Machine selection (`MACHINE ?= "raspberrypi4-64"`), parallelism settings (`BB_NUM_THREADS`, `PARALLEL_MAKE`), disk monitoring, **distro selection** (`DISTRO`)
- **`bblayers.conf`**: Layer ordering (critical for recipe precedence):
  - Poky base layers first (`meta`, `meta-poky`, `meta-yocto-bsp`)
  - Third-party layers (`meta-openembedded`, BSP layers)
  - Custom layers last (`meta-risingembeddedmx`)
  - Paths use **absolute container paths** (`/home/yocto/workspace/...`)

### Layer Dependencies (RPi4 with Custom Distro)
1. `poky/meta` - OE-Core
2. `poky/meta-poky` - Poky distro
3. `meta-openembedded/meta-oe` - Extra recipes
4. `meta-raspberrypi` - RPi-specific BSP
5. `meta-risingembeddedmx` - Custom distro & images (depends on above)

### Docker Integration Details
- **Working directory**: `/home/yocto/workspace` (mounted from repo root)
- **Build output persisted to**: Docker volumes (`yocto-downloads`, `yocto-sstate`, `yocto-build`)
- **Board selection**: Container env var `BOARD=${BOARD:-rpi4}` (defaults to rpi4)

## Common Issues & Patterns

### Recipe Not Found Errors
- **Cause**: Layer not in `bblayers.conf` or listed after dependent layers
- **Fix**: Verify layer path is absolute from container perspective (`/home/yocto/workspace/...`)
- **Debug**: Run `bitbake-layers show-layers` to verify layer registration

### Distro Not Found
- **Cause**: `DISTRO = "risingembeddedmx"` in `local.conf` but layer not registered
- **Fix**: Ensure `meta-risingembeddedmx` is in `bblayers.conf` **before** build initialization

### Image Build Failures
- **Common**: Missing dependencies in custom image recipe
- **Fix**: Check `IMAGE_INSTALL` references valid recipe names (use `bitbake -s` to list all recipes)

### Disk Space Monitoring
`local.conf` contains `BB_DISKMON_DIRS` - ensures minimum free space. If builds fail with cryptic errors, check `/tmp` and build partition (BitBake reports exact failures).

### Parallel Build Tuning
Current settings: `BB_NUM_THREADS ?= "12"`, `PARALLEL_MAKE ?= "-j 12"` - adjust based on container resource limits.

### Shared State Cache
- **sstate** (~20GB) persists across builds and speeds subsequent builds by 5-10x
- Located in Docker volume `yocto-sstate`
- Safe to wipe if rebuilding from scratch

## File References
- [boards/rpi4/conf/local.conf](../../boards/rpi4/conf/local.conf) - Machine & distro config
- [boards/rpi4/conf/bblayers.conf](../../boards/rpi4/conf/bblayers.conf) - Layer configuration
- [boards/rpi4/meta-risingembeddedmx/](../../boards/rpi4/meta-risingembeddedmx/) - Custom distro layer


## When to Modify What

| Issue | File to Check |
|-------|---|
| Add/remove layers | `boards/{board}/conf/bblayers.conf` |
| Change distro | `boards/{board}/conf/local.conf` (`DISTRO` variable) |
| Add distro policies | `boards/{board}/meta-risingembeddedmx/conf/distro/risingembeddedmx.conf` |
| Add packages to custom image | `boards/{board}/meta-risingembeddedmx/recipes-risingembeddedmx/image/risingembeddedmx-image.bb` |
| Create new recipe | Add `.bb` file to appropriate `recipes-*` subdirectory |
| Modify kernel config | Edit `meta-risingembeddedmx/recipes-kernel/kconf/files/fragment.cfg` |
| Change kernel, image features | `boards/{board}/conf/local.conf` |
| Add new board | Create `boards/{new-board}/` with Poky submodule + layer submodules |
| Container dependencies | `Dockerfile` (rebuild with `docker compose build --no-cache`) |
| Build parallelism / caching | `local.conf` (BB_NUM_THREADS, SSTATE settings) |