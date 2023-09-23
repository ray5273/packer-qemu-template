source "qemu" "example" {
  iso_urls         = ["file:///home/sh/packer-qemu/ubuntu-22.04.2-live-server-amd64.iso","http://old-releases.ubuntu.com/releases/22.04/ubuntu-22.04.2-live-server-amd64.iso"]
  iso_checksum     = "sha256:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
  output_directory = "output"
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
  disk_size        = "30G"
  format           = "qcow2"
  accelerator      = "kvm"
  http_directory   = "http"
  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_pty	   = true
  ssh_timeout      = "20m"
  machine_type     = "pc-q35-7.1"
  cpu_model        = "EPYC-Rome"
  cpus		   = 6
  memory           = 4096
  vm_name          = "2204-live-server"
  net_device       = "virtio-net"
  disk_interface   = "virtio-scsi"
  boot_wait        = "20s"
  boot_command = [
	"c",
	"linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ",
	"<enter><wait>",
	"initrd /casper/initrd<enter><wait>",
	"boot<enter>"
  ]
  use_default_display = true
  headless	      = true
  qemuargs = [ # Depending on underlying machine the file may have different location
    ["-bios", "/usr/share/OVMF/OVMF_CODE.fd"]
  ] 
}

build {
  sources = ["source.qemu.example"]
  provisioner "shell" {
    inline = [ "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for Cloud-Init...'; sleep 1; done" ]
  }
}


