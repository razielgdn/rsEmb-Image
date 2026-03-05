DESCRIPTION = "Example to learn how to use a helloworld application"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

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

