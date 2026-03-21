SUMMARY = "Create a local default user on first boot"
DESCRIPTION = "Installs a generic default-user config and a systemd oneshot service that creates a local user at first boot."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://default-user.conf \
    file://default-user-setup.sh \
    file://default-user-setup.service \
"

inherit systemd

SYSTEMD_SERVICE:${PN} = "default-user-setup.service"
SYSTEMD_AUTO_ENABLE = "enable"

RDEPENDS:${PN} = "shadow"

do_install() {
    install -d ${D}${sysconfdir}
    install -m 0600 ${WORKDIR}/default-user.conf ${D}${sysconfdir}/default-user.conf

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/default-user-setup.sh ${D}${bindir}/default-user-setup.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/default-user-setup.service ${D}${systemd_system_unitdir}/default-user-setup.service
}

FILES:${PN} += "${systemd_system_unitdir}/default-user-setup.service"
