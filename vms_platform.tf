# variable "vm_db_name" {
#   type        = string
#   default     = "netology-develop-platform-db"
# }

variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v4a"
}

# variable "vm_db_resources" {
#   type = map(number)
#   default = {
#     cores         = 2
#     memory        = 2
#     core_fraction = 20
#   }
# }

variable "vm_db_zone" {
  type        = string
  default     = "ru-central1-b"
}

variable "vm_db_vpc_name" {
  type        = string
  default     = "db"
  description = "VPC network & subnet name"
}

variable "vm_db_cidr" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
}
