locals {
  project     = "develop-platform"
  env1        = "web"
  env2        = "db"
  vm_web_name = "netology-${local.project}-${local.env1}"
  vm_db_name  = "netology-${local.project}-${local.env2}"
}