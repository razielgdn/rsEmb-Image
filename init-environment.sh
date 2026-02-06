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
#cp $WORKSPACE/boards/$BOARD/conf/* conf/
#echo " " 
#echo "Copied configuration files for $BOARD"
echo "Ready to build for $BOARD. Run: bitbake core-image-minimal"

