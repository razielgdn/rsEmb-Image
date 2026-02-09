#!/bin/bash
set -e
BOARD=${1:-rpi4}
WORKSPACE="/home/yocto/workspace"

if [ ! -d "$WORKSPACE/boards/$BOARD" ]; then
    echo "Error: Board '$BOARD' not found in boards/ directory"
    exit 1
fi

echo "Initializing Yocto for board: $BOARD"
cd "$WORKSPACE/boards/$BOARD/poky"
source oe-init-build-env ../build-$BOARD
echo "Sourced Yocto environment for $BOARD"
# Copy board-specific configuration
cp $WORKSPACE/boards/$BOARD/conf/* conf/
echo " " 
echo "Copied configuration files for $BOARD"

echo "First download required packages"
bitbake --runall fetch core-image-minimal 

echo "Compile gcc to check if your setup can make the process."
bitbake -k gcc

echo "Starting build for $BOARD..."
if bitbake core-image-minimal; then
    echo "Build completed successfully!"
else
    echo "Build failed."
    echo "Advice: Check the logs above. If you see resource errors, try reducing BB_NUM_THREADS in local.conf."
    exit 1
fi
