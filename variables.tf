###cloud vars
variable "cloud_id" {
  type        = string
  default = "b1geap6dpsnun6sh70qj"
}

variable "folder_id" {
  type        = string
  default = "b1gfjo6em0ve76o982vg"
}

variable "vm_web_image_id" {
  type        = string
  default = "ubuntu-2004-lts"
}

variable "vm_web_name" {
  type        = string
  default = "netology-develop-platform-web"
}

variable "vm_web_platform_id" {
  type        = string
  default = "standard-v4a"
}

variable "vm_web_resources" {
  type = map(number)
  default = {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}


###ssh vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILSToR3JR5gmXkTtgSvCezhJDOxkcG2H02REWf1WZye7 ilyas-murtazin@mia-vb"
  description = "ssh-keygen -t ed25519"
}
