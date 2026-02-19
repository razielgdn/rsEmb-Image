SUMMARY = "Recipe for an image for rising embedded os."
DESCRIPTION = "Custom image for rising embedded os based on core-image-base, with additional packages and features."
LICENSE = "MIT"
include recipes-core/images/core-image-base.bb

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
# Set image overhead factor to 1.1
IMAGE_OVERHEAD_FACTOR = "1.1"

# Strip debug symbols and remove build artifacts
#STRIP = "1"
#INHERIT += "rm_work"

# Set the boot partition size to 128MB
BOOT_SPACE = "131072"

# Align the root filesystem to 4KB and add extra space for growth
IMAGE_ROOTFS_ALIGNMENT = "4096"
IMAGE_OVERHEAD_FACTOR = "1.5"
IMAGE_ROOTFS_EXTRA_SPACE = "524288"
