#!/bin/bash

set -e

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

# First argument is board name (e.g., rpi4, aml-s905x for Le Potato)
BOARD=${1:-rpi4}
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
cp "$WORKSPACE/boards/$BOARD/conf/"* conf/
echo " " 
verbose_echo "Copied configuration files for $BOARD"

verbose_echo "First download required packages"

bitbake core-image-minimal --runall=fetch

echo "Starting build for $BOARD..."
if bitbake core-image-minimal; then
    echo "Build completed successfully!"
    end_time=$SECONDS
    duration=$((end_time - start_time))
    echo "Total script time: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
else
    echo "Build failed."
    echo "Advice: Check the logs above. If you see resource errors, try reducing BB_NUM_THREADS in local.conf."
    end_time=$SECONDS
    duration=$((end_time - start_time))
    echo "Total script time until failure: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
    exit 1
fi
