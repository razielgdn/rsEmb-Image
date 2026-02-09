# Project log
<!-- This document will record the objectives and scope by date, what has been achieved, and ideas for future development. -->
## February 2, 2026
### Initial Steps
This marks the first commit. The primary objective is to create a minimal image without a graphical interface, providing a solid foundation for further development. The plan is to utilize a container to replicate the process and establish a portable project.
- [x] Research and implement a YAML configuration for the Docker container to support the project.
- [ ] Establish the project structure.
- [ ] Create a non-GUI image.
- [ ] The next objective will be to add a simple GUI to the image.

## February 3, 2026
### Working in the Container
Today, the Dockerfile and docker-compose file were created. I will test the container to take the initial steps in compiling the image.

## February 4, 2026
I worked on improving the Dockerfile and docker-compose configuration to enhance the development environment, while testing Copilot Chat to streamline and accelerate project progress.

## February 5, 2026
Folders were added to accommodate the two boards. The docker-compose.yml file was modified to allow for individual configuration of each board.

The initial BitBake build approach presented challenges. The system failed to compile some packages due to incorrect permission configurations. Additionally, the container crashed, resulting in a kernel panic that could not be resolved.

## February 6, 2026
The container crashed due to issues with file ownership related to the large number of files generated during Yocto compilation. The solution was to create volumes to manage inputs and outputs within the Docker container. I also downgraded the Debian image version from 13 to 12. The compilation is currently in progress.

> Some packages cannot compile on the first attempt, which is common when using BitBake. These packages often need to be compiled manually one at a time, and various minor issues must be fixed—such as corrupted packages that need to be erased and re-downloaded, network disconnections, and similar issues.
> - **gcc-cross-aarch64** was one such package
> - **cmake-native** appears to have an issue and is a dependency for gcc-cross-aarch64
> - Many issues arose because the system RAM wasn't enough. My PC has "only" 16GB, which is not enough to compile **gcc** with **8 threads**. The solution was to configure 4 threads in local.conf for my setup. 

## February 7, 2026
Finally I have a compiled image, I need to test it in a board but all the process is complete, no more error occurs.
I added my friend Felipe Lopez and my brother Abner Guendulain to the project. I hope they help me to improve my ideas here, provide technical support, and contribute with their own projects to this initiative. 

## February 8, 2026
I will document the process more accurately. I am using Gemini to improve this.
