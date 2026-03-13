SUMMARY = "Recipe for an image for rising embedded os."
DESCRIPTION = "Custom image for rising embedded os based on core-image-base, with additional packages and features."
LICENSE = "MIT"
#include recipes-core/images/core-image-base.bb

inherit core-image

# Network services
IMAGE_FEATURES += " ssh-server-dropbear "

# Essential packages
IMAGE_INSTALL += "\
                  linux-firmware-rpidistro-bcm43455 \
                  kernel-modules \
                  nano \  
                  busybox \
                  busybox-udhcpc \
                  wpa-supplicant \
                  wpa-supplicant-cli \
                  wpa-supplicant-passphrase \
                  iproute2 \
                  iw \
                  rfkill \
                  network-setup \
                  "

#Only produce the "rpi-sdimg" image format
IMAGE_FSTYPES = " rpi-sdimg "

# Use a stable image name without timestamps
IMAGE_NAME = "${IMAGE_BASENAME}-${MACHINE}"

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

# Ensure admin binaries are available without full paths in login shells.
ROOTFS_POSTPROCESS_COMMAND += "set_admin_paths;"
ROOTFS_POSTPROCESS_COMMAND += "add_network_tool_symlinks;"

set_admin_paths() {
    if [ -f ${IMAGE_ROOTFS}${sysconfdir}/profile ]; then
        grep -q '/usr/sbin' ${IMAGE_ROOTFS}${sysconfdir}/profile || \
            echo 'export PATH="$PATH:/usr/sbin:/sbin"' >> ${IMAGE_ROOTFS}${sysconfdir}/profile
    fi
}

add_network_tool_symlinks() {
    install -d ${IMAGE_ROOTFS}${bindir}

    for cmd in ip iw wpa_supplicant wpa_cli; do
        if [ -x ${IMAGE_ROOTFS}${sbindir}/$cmd ] && [ ! -e ${IMAGE_ROOTFS}${bindir}/$cmd ]; then
            ln -sf ${sbindir}/$cmd ${IMAGE_ROOTFS}${bindir}/$cmd
        elif [ -x ${IMAGE_ROOTFS}${base_sbindir}/$cmd ] && [ ! -e ${IMAGE_ROOTFS}${bindir}/$cmd ]; then
            ln -sf ${base_sbindir}/$cmd ${IMAGE_ROOTFS}${bindir}/$cmd
        fi
    done
}
