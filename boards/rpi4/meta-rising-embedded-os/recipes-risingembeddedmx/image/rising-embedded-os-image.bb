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
                  openssh-sftp-server \
                  network-setup \
                  default-user \
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
ROOTFS_POSTPROCESS_COMMAND += "link_sbin_binaries_to_bin;"

# Appends /usr/sbin and /sbin to the global PATH in /etc/profile so that
# admin binaries (e.g. ip, iptables) are accessible from login shells
# without requiring full paths.
set_admin_paths() {
    # Only modify profile if the file exists in the image rootfs
    if [ -f ${IMAGE_ROOTFS}${sysconfdir}/profile ]; then
        # Append the PATH extension only if it is not already present
        grep -q '/usr/sbin' ${IMAGE_ROOTFS}${sysconfdir}/profile || \
            echo 'export PATH="$PATH:/usr/sbin:/sbin"' >> ${IMAGE_ROOTFS}${sysconfdir}/profile
    fi
}

# Creates symlinks in /usr/bin for every executable found in /sbin and /usr/sbin.
# This makes admin tools reachable from non-login shells or restricted environments
# where PATH does not include the sbin directories.
link_sbin_binaries_to_bin() {
    # Ensure the target directory exists in the image rootfs
    install -d ${IMAGE_ROOTFS}${bindir}

    # Iterate over both sbin source directories
    for srcdir in ${IMAGE_ROOTFS}${base_sbindir} ${IMAGE_ROOTFS}${sbindir}; do
        # Skip if the source directory does not exist
        [ -d "$srcdir" ] || continue

        for src in "$srcdir"/*; do
            # Skip non-regular files and non-executables
            [ -f "$src" ] || continue
            [ -x "$src" ] || continue

            cmd="$(basename "$src")"
            dest="${IMAGE_ROOTFS}${bindir}/$cmd"

            # Skip if a file or symlink already exists at the destination
            [ -e "$dest" ] && continue

            # Strip the rootfs prefix to get the absolute in-image path for the symlink target
            rel="${src#${IMAGE_ROOTFS}}"
            ln -sf "$rel" "$dest"
        done
    done
}
