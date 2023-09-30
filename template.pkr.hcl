packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
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

variable "ssh_password" {
  type    = string
  default = "ubuntu"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
  description = "If you want to change username, check http/user-data::user-data::users::name. username must be same."
}

variable "machine_type"{
  type    = string
  default = "q35"
  description = "If your target system is x86_64, use q35. If your target system is aarch64, use virt,highmem=on"
}

variable "accelerator"{
  type    = string
  default = ""
  description = "x86 : kvm, aarch64 (Mac M1) : hvf"
}

variable "cpu_model"{
  type    = string
  default = "EPYC-Rome"
  description = "cpu model can be changed depending on qemu target system (x86, aarch64), x86: EPYC-Rome, aarch64: host"
}

variable "output_directory"{
  type    = string
  default = "output"
}

variable "disk_size"{
  type    = string
  default = "15G"
}

variable "cpus"{
  type    = number
  default = 10
}

variable "memory"{
  type    = number
  default = 4096
}

variable "vnc_bind_address"{
  type    = string
  default = "0.0.0.0"
}

variable "iso_file_name"{
  type    = string
  default = "ubuntu-22.04.2-live-server-amd64.iso"
}

variable "iso_checksum"{
  type    = string
  default = "5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
  description = "ubuntu2204-amd64:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931, ubuntu2204-arm64:12eed04214d8492d22686b72610711882ddf6222b4dc029c24515a85c4874e95"
}

variable "qemu_binary"{
 type     = string
 default  = "qemu-system-x86_64"
}

variable "vm_name" {
  type    = string
  default = "ubuntu-server-22-04-2-amd64-template"
}

source "qemu" "template" {
  qemu_binary      = "${var.qemu_binary}"
  iso_urls         = [
	"file:///Users/sanghyeok/packer-qemu-template/${var.iso_file_name}",
	"http://old-releases.ubuntu.com/releases/22.04/${var.iso_file_name}"
  ]
  iso_checksum     = "sha256:${var.iso_checksum}"
  output_directory = var.output_directory
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
  disk_size        = var.disk_size
  format           = "qcow2"
  accelerator      = var.accelerator
  vnc_bind_address = var.vnc_bind_address
  http_directory   = var.http_directory
  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_pty	       = true
  ssh_timeout      = "60m"
  machine_type     = var.machine_type
  cpu_model        = var.cpu_model
  cpus		       = var.cpus
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
  skip_compaction     = true
  headless	      = var.headless
  qemuargs = [ # Depending on underlying machine the file may have different location
    ["-bios", "./OVMF/OVMF_efi_target_system_is_x86.fd"],
	["-boot", "d"]
  ] 
}

build {
  sources = ["source.qemu.template"]
  provisioner "shell" {
    inline = [ "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for Cloud-Init...'; sleep 1; done" ]
  }

  provisioner "ansible" {
    playbook_file = "./ansible/playbook.yml"
    groups = ["qemu_group"]
    use_proxy = true
	user = "${var.ssh_username}"
    ansible_env_vars = [
	"ANSIBLE_HOST_KEY_CHECKING=False",
	"ansible_ssh_user=${var.ssh_username}",
	"ansible_ssh_pass=${var.ssh_password}"
    ]
	# ansible_python_interpreter parameter must be needed because packer-qemu-ansible hangs when finding remote python interpreter
	extra_arguments = [
	    "-vv",
        "--extra-vars",
        "ansible_python_interpreter=/usr/bin/python3"
    ]
  }

  post-processor "compress" {
    output = "ubuntu-2204-server.dd.gz"
  }
}


