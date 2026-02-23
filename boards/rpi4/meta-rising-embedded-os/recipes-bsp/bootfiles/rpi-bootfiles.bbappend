SUMMARY = "This is a file to learn how to a bbappend works"

BCM2711_DIR = "bcm2711-bootfiles"

do_deploy:append() {
    bbnote "BCM2711 custom deploy: Starting"
    bbnote "Creating custom bootfiles directory: ${DEPLOYDIR}/${BCM2711_DIR}"
    
    install -d ${DEPLOYDIR}/${BCM2711_DIR}

    for i in ${S}/*.elf ; do
        bbnote "Copying .elf: $i"
        cp $i ${DEPLOYDIR}/${BCM2711_DIR}/
    done
    
    for i in ${S}/*.dat ; do
        bbnote "Copying .dat: $i"
        cp $i ${DEPLOYDIR}/${BCM2711_DIR}/
    done

    for i in ${S}/*.bin ; do
        bbnote "Copying .bin: $i"
        cp $i ${DEPLOYDIR}/${BCM2711_DIR}/
    done
    
    bbnote "Copying overlays"
    if [ -d ${S}/overlays ]; then
        cp -r ${S}/overlays/ ${DEPLOYDIR}/${BCM2711_DIR}/
    fi
    
    bbnote "BCM2711 custom deploy: Completed"
}