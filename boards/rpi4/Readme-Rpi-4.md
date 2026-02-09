# Raspberry Pi 4 Build Configuration

# Building the Image
First approach
1. Navigate to the directory: ```cd boards/rpi4/poky/```.
2. execute ```source oe-init-build-env build-rpi4```.
3. Configure your `local.conf`. 
  You can copy the file `./conf/local.conf` folder
4. Configure the `bblayers.conf`.
  You can copy the file  `./conf/bblayers.conf`. 
5. First download required packages: 
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
## Build script
A buid script was created to improve the process. At this moment of the development you can run the script:

```bash
./build-project.sh
```


## Output

