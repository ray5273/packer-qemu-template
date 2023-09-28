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
- [ ] Add Ansible Provisioning
- [x] Upgrade QEMU version and check compatibility (solution: v8.0.2 checked in WSL2 env)
- [ ] Add automatic deploy is possible with any tools (e.g. vagrant, canonical maas)
- [x] Check packer-maas : https://github.com/canonical/packer-maas/tree/main/ubuntu
- [ ] Consider make CI/CD pipeline for QEMU image

## Install QEMU

- install libslirp v4.7.0 (from https://gitlab.freedesktop.org/slirp/libslirp.git)
- install QEMU v8.0.2 (./configure --enable-slirp needed)
- install libvirtd 9.2.0 (https://download.libvirt.org/)

## How To Build QEMU image with Packer

Build QEMU image by running following command

```
PACKER_LOG=1 packer build --force template.pkr.hcl
```

or more specific command

```
PACKER_LOG=1 packer build -only=qemu.example --force .
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

in case of building image without KVM accelerate, it can take more time than 1 Hour (Takes 1 Hour 16 minutes with following options : without accelerate, cpu=3, memory=4096 option).

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
- vnc 0.0.0.0:1 means access vnc is possible from any_address:5901
- NOTE : -nographic -serial mon:stdio option does not support in 
``` 
qemu-system-x86_64 -name 22-04-live-server \               
-netdev user,id=user.0,hostfwd=tcp::4141-:22 \              
-device virtio-net,netdev=user.0 \  
-drive file=./output/ubuntu-server-22-04-2-amd64-template,if=virtio,cache=writeback,discard=ignore,format=qcow2 \              
-machine type=q35,accel=kvm \              
-smp 4 \
-m 4096M \
-bios /usr/share/OVMF/OVMF_CODE.fd \
-vnc 0.0.0.0:1
```

## How to set vnc server in QEMU running server
- vnc_bind_address set "0.0.0.0" in template.pkr.hcl
- open inbound ports if you use cloud services (Azure, AWS, GCP)
- open firewall like following commands
```
# open 5900~6000 port
sudo ufw allow 5900:6000/tcdp
sudo ufw allow 5900:6000/udp

# restart firewall setting
sudo ufw disable
sudo ufw enable

sudo ufw status
``` 

## How to upload template file

- Refer following link (https://maas.io/docs/how-to-customise-images#heading--how-to-upload-packer-images-to-maas)
- Need packer packages for generating Ubuntu template.
```
sudo apt install packer
sudo apt install qemu-utils
sudo apt install qemu-system
sudo apt install ovmf
sudo apt install cloud-image-utils
```

- Upload packer image to MAAS

```
$ maas admin boot-resources create \
    name='custom/ubuntu-raw' \
    title='Ubuntu Custom RAW' \
    architecture='amd64/generic' \
    filetype='ddgz' \
    content@=ubuntu-2204-server.dd.gz
```

