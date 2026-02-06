# AML-S905X-CC (Libre Computer) Build Configuration

## BSP Layer
- **meta-amlogic**: https://github.com/superna9999/meta-amlogic

## Build
```bash
./init-board.sh aml-s905x-cc
bitbake core-image-minimal
```

## Output
Image artifacts: `/home/yocto/build-aml-s905x-cc/tmp/deploy/images/`
