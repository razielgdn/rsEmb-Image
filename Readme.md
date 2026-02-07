# Introduction
This repo will contain my discovers to implements Yocto project in a raspberry pi board and document the process. 

## Objectives
This repo have the purpose to create a stable raspberry Pi 4 image to use to learn the basics about embedded linux and use it to create a useful project to implements my personal knowledge. 


## How to work with the container.
- Build the image:   
``` docker compose up -d```

- Run the container:   
```docker run -it --rm -v $(pwd):/home/yocto/workspace yocto-builder```

- Check the docker process:   
```docker ps ```
- Check the images
 ```docker images ```
- Stop the container:   
```docker stop <ID>```

## to compile docker
First approach 
1. go to ```cd boards/rpi4/poky/``` 
2. execute ```source oe-init-build-env build-rpi4```
3. ```bitbake --runall fetch core-image-minimal ```
4. ```bitbake core-image-minimal ```
5. Some error can appear in the process this errors many times are ocationated by corrupted files or network connection issues, many of them needs only a re-compilation. Check the log and decide the best way to do this.  For example in my compilation fails the package gcc-cross-aarch64. The solution was:
    - Execute the command ```bitbake -k <package>``` repeatedly until successful.
    - The problem need to erase the configuration and rebuild ```rm -rf /home/yocto/tmp/work/x86_64-linux/gcc-cross-aarch64/* ``` and rerun bitbake.
      ``` bitbake -k gcc-cross-aarch64```

## monitoring the host process
```htop ```