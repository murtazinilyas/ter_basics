terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=1.12.0"
}

provider "yandex" {
  # token     = var.token
  cloud_id                 = "b1geap6dpsnun6sh70qj"
  folder_id                = "b1gfjo6em0ve76o982vg"
  zone                     = var.default_zone
  service_account_key_file = file("~/.authorized_key.json")
}
