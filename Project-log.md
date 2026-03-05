# Project log
<!-- This document will record the objectives and scope by date, what has been achieved, and ideas for future development. -->
## Objectives

<!--- [ ] The next objective will be to add a simple GUI to the image. -->


### [ ] Create a recipe to define a custom distro 
- [ ] Create the project structure and define the basics of the distro. 
- [ ] Creation of the 

<!--Mark the checkbox when finished all the the tasks-->
### [ ] Create a stable image from poky 
The primary objective is to create a minimal image without a graphical interface, providing a solid foundation for further development. The plan is to utilize a container to replicate the process and establish a portable project.
- [x] Research and implement a YAML configuration for the Docker container to support the project.
- [x] Establish the project structure.
- [x] Create a non-GUI image.
- [ ] Test the image on a Raspberry Pi 4 board 


## March 1, 2026
The project is progressing well. The Docker container is set up and configured to support the Yocto
I need to move the structure of the project to comply with scarthgap and add more bbappend examples. 
I am near to publish the procedure to create the meta-risingembeddedmx layer in my blog. 

## February 12, 2026
When you work with .bb files and .conf files remember the spaces between quotes for example:
```python
DISTRO_FEATURES:append = " systemd \
                          wifi    \
                          opengl  \
                          pam \
                          pulseaudio \
                          egl \
                          usrmerge \  
                          alsa-plugins "
```
I lost an hour because I did not put a space:
```diff
-DISTRO_FEATURES:append = "systemd \
+DISTRO_FEATURES:append = " systemd \
                          wifi    \
                          opengl  \
```                            
## February 11, 2026
For the record: Docker crashed when all the resources of the PC were available for compilation. That sounds like a contradiction, and I don't know why it happens, but after a very long headache (lasting 9 days), the solution turned out to be quite mundane.

My PC has a Ryzen 5 5600G processor and 16GB of RAM, which is powerful enough for my needs. However, to compile without issues, I needed to configure the Docker container with:
- 12GB of RAM
- 10 threads

## February 10, 2026
I discovered that the issue was actually my Docker setup. The `debian:12-slim` image lacked several essential host packages required by BitBake to build `-native` tools.
After installing the missing dependencies, the compilation was successful.
The Dockerfile and build scripts have been updated accordingly.

The next step is to create the configuration for a custom distribution.


## February 9, 2026

While attempting to recreate the build, the system crashed again. I am investigating the root cause. During this process, several packages failed multiple times:
 - curl-native
 - cmake-native
 - gcc
 - libsolv
 - libsolv-native
 - libmodulemd
 - libmodulemd-native
 - swig-native
 - gnutls
Despite having a correctly configured `local.conf`, I encountered another kernel panic. The investigation continues; I suspect my PC's hardware limitations (RAM and CPU) might be the bottleneck.


## February 8, 2026
I will document the process more accurately. I am using Gemini to improve this.


## February 7, 2026
Finally, I have a compiled image. I need to test it on a board, but the process is complete, and no more errors occur.
I added my friend Felipe Lopez and my brother Abner Guendulain to the project. I hope they help me improve my ideas, provide technical support, and contribute their own projects to this initiative. 


## February 6, 2026
The container crashed due to issues with file ownership related to the large number of files generated during Yocto compilation. The solution was to create volumes to manage inputs and outputs within the Docker container. I also downgraded the Debian image version from 13 to 12. The compilation is currently in progress.

> Some packages cannot compile on the first attempt, which is common when using BitBake. These packages often need to be compiled manually one at a time, and various minor issues must be fixed—such as corrupted packages that need to be erased and re-downloaded, network disconnections, and similar issues.
> - **gcc-cross-aarch64** was one such package
> - **cmake-native** appears to have an issue and is a dependency for gcc-cross-aarch64
> - Many issues arose because the system RAM wasn't enough. My PC has "only" 16GB, which is not enough to compile **gcc** with **8 threads**. The solution was to configure 4 threads in local.conf for my setup. 


## February 5, 2026
Folders were added to accommodate the two boards. The docker-compose.yml file was modified to allow for individual configuration of each board.

The initial BitBake build approach presented challenges. The system failed to compile some packages due to incorrect permission configurations. Additionally, the container crashed, resulting in a kernel panic that could not be resolved.

## February 4, 2026
I worked on improving the Dockerfile and docker-compose configuration to enhance the development environment, while testing Copilot Chat to streamline and accelerate project progress.

## February 3, 2026
### Working in the Container
Today, the Dockerfile and docker-compose file were created. I will test the container to take the initial steps in compiling the image.


## February 2, 2026
### Initial Steps
This marks the first commit. Started defining the structure, Dockerfile, docker-compose, and all necessary paths and files. 