# packer-qemu-template
Packer Qemu Template 

# How To Run
`PACKER_LOG=1 packer build template.pkr.hcl`

# Known Issue
- cannot login to server
- ssh connection failed

# Password Generation
`openssl passwd -6 -salt xyz`
