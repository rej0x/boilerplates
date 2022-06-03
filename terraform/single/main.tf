terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.10"
    }
  }
}

provider "proxmox" {
    pm_api_url = "https://proxmoxxx:8006/api2/json"
    pm_api_token_id = "terraform-prov@pve!mytoken"
    pm_api_token_secret = "670dfd54-41ff-41c2-a887-553e7d7c167c"
    #    pm_user = "root"
    #    pm_password = "hg3n6ek9"
    pm_tls_insecure = true
    #    pm_log_enable = true
    #    pm_log_file = "terraform-plugin-proxmox.log"
    #    pm_debug = true
    #    pm_log_levels = {
    #      _default = "debug"
    #      _capturelog = ""
    #}
}

resource "proxmox_vm_qemu" "test_server" {
  count = 1
  name = "test-vm-${count.index + 1}"
  target_node = var.proxmox_host
  clone = var.template_name
  agent = 1
  os_type = "cloud-init"
  cores = 1
  sockets = 1
  cpu = "host"
  memory = 2048
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    size = "10G"
    type = "scsi"
    storage = "local-lvm"
    iothread = 1
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=192.168.1.24${count.index + 1}/24,gw=192.168.1.1"

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
