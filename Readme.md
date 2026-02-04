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


