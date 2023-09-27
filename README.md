# packer-qemu-template

Packer QEMU Template for Ubuntu 22.04.02 live server 

## Prerequisite
- Packer (v1.9.4)
- Pakcer Plugin Qemu (v1.0.9)
- QEMU (7.1.0, v8.0.2 (slirp enabled))

## TODO list

- [x] Check apt source address can be changed (solution: add apt sources in http/user-data)
- [x] Add Variable hcl file (solution : add variables in template.pkr.hcl file)
- [ ] Add network configuration shell script
- [ ] Check bridge setting 
- [ ] Check Ansible Provisioning or Shell Provisioning
- [x] Upgrade QEMU version and check compatibility (solution: v8.0.2 checked in WSL2 env)
- [ ] Add automatic deploy is possible with any tools (e.g. vagrant, canonical maas)
- [ ] Check packer-maas : https://github.com/canonical/packer-maas/tree/main/ubuntu
- [ ] Consider make CI/CD pipeline for QEMU image

## Install QEMU

- install libslirp v4.7.0 (from https://gitlab.freedesktop.org/slirp/libslirp.git)
- install QEMU v8.0.2 (./configure --enable-slirp needed)

## How To Build QEMU image with Packer

Build QEMU image by running following command

```
PACKER_LOG=1 packer build --force template.pkr.hcl
```

Expected build result in case of success

```
2023/09/24 23:37:03 [INFO] (telemetry) ending qemu.example
==> Wait completed after 13 minutes 55 seconds
Build 'qemu.example' finished after 13 minutes 55 seconds.
==> Builds finished. The artifacts of successful builds are:

2023/09/24 23:37:03 machine readable: qemu.example,artifact-count []string{"1"}
==> Wait completed after 13 minutes 55 seconds
```

in case of building image without KVM accelerate, it can take more than 55 minutes.

## Password Generation in http/user-data

`openssl passwd -6 -salt xyz`

result of following command should be added in user-data
```
#cloud-config
user-data:
  users:
    - name: ubuntu
      passwd: "{Add openssl result here}"

```

## How To Run QEMU image built by Packer
- bios option needed ( if bios option doesn't exist, boot hangs )

``` 
qemu-system-x86_64 -name 22-04-live-server \               
-netdev user,id=user.0,hostfwd=tcp::4141-:22 \              
-device virtio-net,netdev=user.0 \  
-drive file=./output/ubuntu-server-22-04-2-amd64-template,if=virtio,cache=writeback,discard=ignore,format=qcow2 \              
-machine type=q35,accel=kvm \              
-smp 4 \
-m 4096M \
-bios /usr/share/OVMF/OVMF_CODE.fd
```

## How to set vnc server
- vnc_bind_address set "0.0.0.0" in template.pkr.hcl
- open inbound ports if you use cloud services (Azure, AWS, GCP)
- open firewall like following commands
```
sudo ufw allow 5900:6000/tcdp
sudo ufw allow 5900:6000/udp

sudo ufw disable
sudo ufw enable

sudo ufw status
``` 

