# Raspberry Pi 4 Build Configuration

## BSP Layer
- **meta-raspberrypi**: https://github.com/agherzan/meta-raspberrypi

## Build
```bash
./init-board.sh rpi4
bitbake core-image-minimal
```

## Output
Image artifacts: `/home/yocto/build-rpi4/tmp/deploy/images/raspberrypi4-64/`
