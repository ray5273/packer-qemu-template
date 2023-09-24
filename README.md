# packer-qemu-template

Packer QEMU Template for Ubuntu 22.04.02 live server 

## Prerequisite
- Packer (v1.9.4)
- Pakcer Plugin Qemu (v1.0.9)
- QEMU (7.1.0, v8.0.2 (slirp enabled))

## TODO list

- [x] Check apt source address can be changed (solution: add apt sources in http/user-data)
- [ ] Add Variable hcl file
- [ ] Add network configuration shell script
- [ ] Check bridge setting 
- [ ] Check Ansible Provisioning or Shell Provisioning
- [x] Upgrade QEMU version and check compatibility (solution: v8.0.2 checked in WSL2 env)
- [ ] Add automatic deploy is possible with any tools (e.g. vagrant, canonical maas)
- [ ] Check packer-maas : https://github.com/canonical/packer-maas/tree/main/ubuntu

## How To Build QEMU image with Packer
`PACKER_LOG=1 packer build --force template.pkr.hcl`

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
-drive file=./output/2204-live-server,if=virtio,cache=writeback,discard=ignore,format=qcow2 \              
-machine type=q35,accel=kvm \              
-smp cpus=4,sockets=4 \
-m 4096M \
-bios /usr/share/ovmf/OVMF.fd
```
