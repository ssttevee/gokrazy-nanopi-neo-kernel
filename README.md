This repo is a fork of https://github.com/gokrazy/kernel.

# gokrazy NanoPi NEO kernel repository

This repository holds a pre-built Linux kernel image for NanoPi NEO from FriendlyElec, used by the [gokrazy](https://github.com/gokrazy/gokrazy) project.

## Usage

Add these fields to your `config.json`

```
{
    ...
    "DeviceType": "nanopi_neo",
    "KernelPackage": "github.com/ssttevee/gokrazy-nanopi-neo-kernel",
    "FirmwarePackage": "",
    "EEPROMPackage": ""
}
```

The files in this repository are automatically included by `gok`, so no direct interaction with this repository is required for regular usage.

## Updating the kernel

run the `build.sh` script
