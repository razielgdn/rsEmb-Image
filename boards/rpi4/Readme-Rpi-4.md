# Raspberry Pi 4 Build Configuration
## Overview
## Process for building a minimal image:
First approach
1. Navigate to the directory: ```cd boards/rpi4/poky/```.
2. Execute ```source oe-init-build-env build-rpi4```.
3. Configure your `local.conf`. 
  You can copy the file from the `./conf/local.conf` folder.
4. Configure the `bblayers.conf`.
  You can copy the file from `./conf/bblayers.conf`. 
5. Download required packages first: 
   ```bash 
     bitbake --runall fetch core-image-minimal 
   ```
6. Build an image:
    ```bash 
     bitbake core-image-minimal 
    ```
7. Some errors may appear during the process. These errors are often caused by corrupted files or network connection issues; many of them need only a re-compilation. Check the log and decide the best way to proceed. For example, in my compilation, the package gcc-cross-aarch64 failed. The solution was:
  - Execute the command `bitbake -k <package>` repeatedly until successful.
  - The problem required erasing the configuration and rebuilding: 
    ```bash
      rm -rf /home/yocto/tmp/work/x86_64-linux/gcc-cross-aarch64/*
    ```      
    - Rerunning bitbake: 
    ```bash
      bitbake -k gcc-cross-aarch64
    ```
> This process was needed to compile an image manually, the build-project.sh script automates some steps for the minimal image. 

## Output
The image to flash in the Raspberry pi 4 board will be stored in `boards/rpi4/build-rpi4/raspberrypi4-64-imege-to-flash.tar.bz2`