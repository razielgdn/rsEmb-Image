DESCRIPTION = "Example to learn how to use a helloworld application"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
# SRC_URI = "file://hello.c"
##  Documentation pus examples of urls
##  SRC_URI = "git://github.com/fronteed/icheck.git;protocol=https;branch=${PV};tag=${PV}"
##  SRC_URI = "git://github.com/asciidoc/asciidoc-py;protocol=https;branch=main"
##  SRC_URI = "git://git@gitlab.freedesktop.org/mesa/mesa.git;branch=main;protocol=ssh;..."##

SRC_URI = "git://github.com/razielgdn/custom-application-test.git;protocol=https;branch=main"
SRCREV = "${AUTOREV}"
#BB_STRICT_CHECKSUM = "0"
S = "${WORKDIR}/git"

# S = "${WORKDIR}"
do_compile(){
    # Your code here #
     ${CC} hello.c -o hello ${LDFLAGS}
    # oe_runmake 
    
}
do_install(){
    # Your code here
            install -d ${D}${bindir}
            install -m 0777 hello ${D}${bindir}/
}

