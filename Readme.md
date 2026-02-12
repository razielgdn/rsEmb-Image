# Introduction
This repo contains my findings while implementing the Yocto Project on a Raspberry Pi board and documents the process.

## Overview
This project creates a custom Linux image to run on a Raspberry Pi 4 board, using the **Yocto Project** in its **Scarthgap** version. It demonstrates the complete workflow of configuring and building a minimal embedded Linux distribution with customizable recipes and board-specific configurations.

## Objectives
The purpose of this repo is to create a stable Raspberry Pi 4 image, learn the basics of embedded Linux, and apply this knowledge to a useful project.

## Download the project
[rsEmb-Image](https://github.com/razielgdn/rsEmb-Image.git) project can be cloned using the following command:

```bash
git clone https://github.com/razielgdn/rsEmb-Image.git
cd rsEmb-Image
```

## How to work with the container
- Build the image:   
 ```bash
  docker compose up -d --build
 ```

- Run the container:   

 ```bash    
  docker compose exec yocto bash
 ```  
- Stop the container:   
 ```bash 
  docker compose down
 ```

## Project Information
This project serves as an example to demonstrate how to configure and develop using the **Yocto Project**.

The main goal is to provide the necessary recipes to build a custom Linux distribution that can run on two boards:

- **Raspberry Pi 4**
- **Libre Computer Le Potato (AML-S905X-CC)**

- The script **[build-project.sh](build-project.sh)** contains all the steps needed to set up the environment and build an image for a selected board.  
  It will be updated and improved as the project matures.

- To build an image inside the container, you only need to make the script executable and run it:

```bash
chmod +x build-project.sh
./build-project.sh -h # To see the help of the script
./build-project.sh -v # To run the verbose mode 
```   

- The custom **meta-risingembeddedmx** layer provides a feature-rich image with:
  - **SSH Server**: Dropbear SSH server for remote access
  - **Network Support**: NetworkManager for network configuration, NFS utilities, and WiFi connectivity (BCM43430 firmware)
  - Additional tools: rsync for file synchronization and NTFS filesystem support
  
- Detailed instructions and board-specific information for the Raspberry Pi 4 can be found in:
[Readme-Rpi-4.md](boards/rpi4/Readme-Rpi-4.md).
- The development progress, daily challenges, decisions, and notes are documented in:
[Project-log.md](Project-log.md).
More detailed write-ups, explanations, tips & tricks, and lessons learned will be published on my blog:
[Rising Embedded MX](https://razielgdn.github.io/risingembeddedmx/projects/en/yocto/intro/build-raspberrypi) (more articles will be added over time).
<!--Links to define-->

## Useful commands to this project
### Docker commands:
- Check the docker process:   
  ```bash
    docker ps
  ```
- Check the images:
  ```bash
    docker images
  ```
- Check the volumes:
  ```bash
    docker volume ls
  ```
### SO host
- Monitor the host: `htop`
  
