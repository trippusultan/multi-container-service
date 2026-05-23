terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.39"
    }
  }
}

variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "Name of the SSH key in DigitalOcean to inject into the droplet"
  type        = string
}

variable "server_name" {
  description = "Hostname for the droplet"
  type        = string
  default     = "todo-api-server"
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "todo_api" {
  name     = var.server_name
  region   = "nyc1"
  size     = "s-2vcpu-4gb"
  image    = "docker-20-04-x64"
  ssh_keys = [var.ssh_key_name]

  tags = ["todo-api", "production"]

  user_data = <<-EOT
    #!/bin/bash
    timedatectl set-timezone UTC
  EOT
}

output "droplet_ip" {
  value       = digitalocean_droplet.todo_api.ipv4_address
  description = "Public IPv4 address of the Droplet"
}

output "droplet_id" {
  value       = digitalocean_droplet.todo_api.id
  description = "ID of the Droplet"
}
