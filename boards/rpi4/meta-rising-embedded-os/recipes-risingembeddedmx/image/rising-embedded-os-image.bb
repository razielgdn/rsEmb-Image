SUMMARY = "Recipe for an image for rising embedded os."
DESCRIPTION = "Custom image for rising embedded os based on core-image-base, with additional packages and features."
LICENSE = "MIT"
#include recipes-core/images/core-image-base.bb

inherit core-image

# Network services
IMAGE_FEATURES += " nfs-server ssh-server-dropbear "

# Essential packages
IMAGE_INSTALL += "\ 
                  linux-firmware-rpidistro-bcm43455 \
                  nfs-utils \
                  networkmanager \
                  nano \
                  vim \
                  "

#Only produce the "rpi-sdimg" image format
IMAGE_FSTYPES = " rpi-sdimg "

#Remove old builds
RM_OLD_IMAGE = "1"

# Add systemd-analyze tool
#IMAGE_INSTALL:append = " systemd-analyze "
# Remove bluetooth packages
IMAGE_INSTALL:remove = " bluez5 obexftp "

# Strip debug symbols and remove build artifacts
#STRIP = "1"
#INHERIT += "rm_work"

# Set the boot partition size to 128MB
BOOT_SPACE = "131072"

# Align the root filesystem to 4KB and add extra space for growth
IMAGE_ROOTFS_ALIGNMENT = "4096"
# Set the overhead factor to account for filesystem metadata and growth
IMAGE_OVERHEAD_FACTOR = "1.5"
# Add extra space (512MB) to the root filesystem to ensure it can grow without running out of space
IMAGE_ROOTFS_EXTRA_SPACE = "524288"
