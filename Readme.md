# Introduction
This repo contains my discoveries implementing the Yocto project on a Raspberry Pi board and documents the process.

## Objectives
The purpose of this repo is to create a stable Raspberry Pi 4 image to learn the basics of embedded Linux and use it to create a useful project to apply my personal knowledge.

## Download the project
```bash
git clone https://github.com/razielgdn/raspberry-yocto.git
cd raspberry-yocto
```

## How to work with the container
- Build the image:   
   ```bash
      docker compose up -d --build
   ```

- Run the container:   
  - `docker run -it --rm -v $(pwd):/home/yocto/workspace yocto-builder` OR
  - `docker exec -it yocto-dev bash`
- Stop the container:   
  ```bash 
    docker stop <ID>
  ```


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
  
