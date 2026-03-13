SUMMARY = "Minimal Wi-Fi setup service using wpa_supplicant and udhcpc"
DESCRIPTION = "Installs a shell script and systemd service that associates \
               wlan0 with the AP defined in /etc/wpa_supplicant.conf and \
               requests a DHCPv4 address at boot."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://network-setup.sh \
    file://network-setup.service \
"

inherit systemd

SYSTEMD_SERVICE:${PN} = "network-setup.service"
SYSTEMD_AUTO_ENABLE = "enable"

RDEPENDS:${PN} = "wpa-supplicant busybox-udhcpc rfkill iproute2"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/network-setup.sh ${D}${bindir}/network-setup.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/network-setup.service ${D}${systemd_system_unitdir}/network-setup.service
}

FILES:${PN} += "${systemd_system_unitdir}/network-setup.service"
