terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.10"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://proxmoxxx:8006/api2/json"
  pm_api_token_id     = "terraform-prov@pve!mytoken"
  pm_api_token_secret = "670dfd54-41ff-41c2-a887-553e7d7c167c"
  pm_tls_insecure     = true
}

resource "proxmox_vm_qemu" "kube_server" {
  count       = 1
  name        = "kube-server-0${count.index + 1}"
  vmid        = "40${count.index + 1}"
  target_node = var.proxmox_host
  clone       = var.template_name
  agent       = 1
  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  cpu         = "host"
  memory      = 2048
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"
  disk {
    slot     = 0
    size     = "10G"
    type     = "scsi"
    storage  = "local-lvm"
    iothread = 1
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  network {
    model  = "virtio"
    bridge = "vmbr17"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=192.168.1.24${count.index + 1}/24,gw=192.168.1.1"
  ipconfig1 = "ip=10.17.0.1${count.index + 1}/24"

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}

resource "proxmox_vm_qemu" "kube_agent" {
  count       = 2
  name        = "kube-agent-0${count.index + 1}"
  vmid        = "50${count.index + 1}"
  target_node = var.proxmox_host
  clone       = var.template_name
  agent       = 1
  os_type     = "cloud-init"
  cores       = 1
  sockets     = 1
  cpu         = "host"
  memory      = 1024
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"

  disk {
    slot     = 0
    size     = "10G"
    type     = "scsi"
    storage  = "local-lvm"
    iothread = 1
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  network {
    model  = "virtio"
    bridge = "vmbr17"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=192.168.1.25${count.index + 1}/24,gw=192.168.1.1"
  ipconfig1 = "ip=10.17.0.2${count.index + 1}/24"

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
