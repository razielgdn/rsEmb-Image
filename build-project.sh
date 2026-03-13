#!/bin/bash

set -e

# Function to display help
show_help() {
    cat << 'EOF'
Usage: ./build-project.sh [OPTIONS] [BOARD] [PROFILE]

Build a Yocto image for Raspberry Pi or other boards.

OPTIONS:
  -h, --help      Show this help message
  -v, --verbose   Enable verbose output for debugging

ARGUMENTS:
  BOARD           Target board (default: rpi4)
                  Supported: 
                    - rpi4: Raspberry Pi 4
                    - lcbPot: Libre Computer AML-S905X-CC (Le Potato) 
                              To be developed in the future, currently only rpi4 is supported 
                  
  PROFILE         Build profile (default: rsEmOs)
                  Supported: 
                    - minimal: Minimal image without GUI
                    - rsEmOs: Rising Embedded OS (custom distribution)

EXAMPLES:
  # Build minimal image for RPi4
  ./build-project.sh minimal rpi4

  # Build Rising Embedded OS for RPi4 (default)
  ./build-project.sh

  # Build minimal image with verbose output
  ./build-project.sh -v minimal rpi4

  # Build for Libre Computer board (aml-s905x-cc) 
  ./build-project.sh lcbPot rising-embedded-os

OUTPUT:
  - Built images are located in: /home/yocto/tmp/deploy/images/BOARD/
    - Final SD image for RPi4: /output/<image-name>-raspberrypi4-64.rpi-sdimg
      (core-image-minimal-raspberrypi4-64 or rising-embedded-os-image-raspberrypi4-64)

TROUBLESHOOTING:
  - If build fails due to resource errors, reduce BB_NUM_THREADS in local.conf
  - Use -v/--verbose flag to see detailed build progress
  - Check BitBake logs in: boards/BOARD/build-BOARD/tmp/work/

EOF
}

# Check for help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

start_time=$SECONDS

VERBOSE=false
if [ "$1" = "-v" ] || [ "$1" = "--verbose" ]; then
    VERBOSE=true
    shift
fi

verbose_echo() {
    if [ "$VERBOSE" = true ]; then
        echo "$@"
    fi
}

# First argument is board name (e.g., rpi4, lcbPot for Libre Computer AML-S905X-CC)
# Optional profile: minimal or rsEmOs (default)
PROFILE=""
BOARD=""

if [ "$1" = "minimal" ] || [ "$1" = "rsEmOs" ]; then
    PROFILE="$1"
    shift
fi

BOARD=${1:-rpi4}
shift || true

if [ -z "$PROFILE" ] && { [ "$1" = "minimal" ] || [ "$1" = "rsEmOs" ]; }; then
    PROFILE="$1"
fi

PROFILE=${PROFILE:-rsEmOs}
WORKSPACE="/home/yocto/workspace"

if [ ! -d "$WORKSPACE/boards/$BOARD" ]; then
    echo "Error: Board '$BOARD' not found in boards/ directory"
    exit 1
fi

echo "Initializing Yocto for board: $BOARD"
verbose_echo "Workspace is at $WORKSPACE"

cd "$WORKSPACE/boards/$BOARD/poky"
source oe-init-build-env ../build-$BOARD
verbose_echo "Sourced Yocto environment for $BOARD"

# Copy board-specific configuration
CONF_DIR="$WORKSPACE/boards/$BOARD/conf"

if [ "$PROFILE" = "minimal" ]; then
    BBLAYERS_SRC="$CONF_DIR/bblayers-minimal.conf"
    LOCAL_SRC="$CONF_DIR/local-minimal.conf"
    BUILD_TARGET="core-image-minimal"
else
    BBLAYERS_SRC="$CONF_DIR/bblayers-rising-embedded-os.conf"
    LOCAL_SRC="$CONF_DIR/local-rising-embedded-os.conf"
    BUILD_TARGET="rising-embedded-os-image"
fi

cp "$BBLAYERS_SRC" conf/bblayers.conf
cp "$LOCAL_SRC" conf/local.conf
echo " " 
verbose_echo "Copied configuration files for $BOARD ($PROFILE)"

verbose_echo "First download required packages"

bitbake "$BUILD_TARGET" --runall=fetch

echo "Starting build for $BOARD ($BUILD_TARGET)..."
if bitbake "$BUILD_TARGET"; then
    echo "Build completed successfully!"
    end_time=$SECONDS
    duration=$((end_time - start_time))
    echo "Total script time: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
    echo "Image available under build-$BOARD/tmp/deploy/images (target: $BUILD_TARGET)"
    echo "copy image to build directory"
    # Copy built image to board directory
    case "$BOARD" in
        rpi4)
            mkdir -p "./output"            
            cp "/home/yocto/tmp/deploy/images/raspberrypi4-64/rising-embedded-os-image-raspberrypi4-64.rpi-sdimg" "./output/image-to-flash.rpi-sdimg"
            ;;
        lcbPot)
            # This will be developed in the future. 
            #cp "/home/yocto/ tmp/deploy/images/aml-s905x-cc/${BUILD_TARGET}-aml-s905x-cc.rootfs-"*.sdimg "../lcbPot-image-to-flash.sdimg"
            ;;
        *)
            echo "Error: Unknown board '$BOARD'"
            exit 1
            ;;
    esac
    if [ "$BOARD" = "rpi4" ]; then
        echo "Image copied to ./output/image-to-flash.rpi-sdimg"
    fi
    
else
    echo "Build failed."
    echo "Advice: Check the logs above. If you see resource errors, try reducing BB_NUM_THREADS in local.conf."
    end_time=$SECONDS
    duration=$((end_time - start_time))
    echo "Total script time until failure: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
    exit 1
fi
