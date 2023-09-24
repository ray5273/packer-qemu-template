packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "headless" {
  type        = bool
  default     = true
  description = "Whether VNC viewer should not be launched."
}

variable "http_directory" {
  type    = string
  default = "http"
}

variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}

variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}

variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "ssh_password" {
  type    = string
  default = "ubuntu"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
  description = "If you want to change username, check http/user-data::user-data::users::name"
}

variable "output_dir" {
  type    = string
  default = "output"
}

variable "vm_name" {
  type    = string
  default = "ubuntu-server-22-04-2-amd64-template"
}

variable "machine_type"{
  type    = string
  default = "q35"
}

variable "cpu_model"{
  type    = string
  default = "EPYC-Rome"
}

variable "output_directory"{
  type    = string
  default = "output"
}

variable "disk_size"{
  type    = string
  default = "60G"
}

variable "cpus"{
  type    = number
  default = 6
}

variable "memory"{
  type    = number
  default = 4096
}

source "qemu" "example" {
  iso_urls         = [
	"file:///home/sh/packer-qemu/ubuntu-22.04.2-live-server-amd64.iso",
	"http://old-releases.ubuntu.com/releases/22.04/ubuntu-22.04.2-live-server-amd64.iso"
  ]
  iso_checksum     = "sha256:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
  output_directory = var.output_directory
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
  disk_size        = var.disk_size
  format           = "qcow2"
  accelerator      = "kvm"
  http_directory   = var.http_directory
  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_pty	   = true
  ssh_timeout      = "20m"
  machine_type     = var.machine_type
  cpu_model        = var.cpu_model
  cpus		   = var.cpus
  memory           = var.memory
  vm_name          = var.vm_name
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  boot_wait        = "20s"
  boot_command = [
	"c",
	"linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ",
	"<enter><wait>",
	"initrd /casper/initrd<enter><wait>",
	"boot<enter>"
  ]
  use_default_display = true
  headless	      = var.headless
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


