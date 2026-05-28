output "vm_info" {
    value= {
        vm_web = {
            instance_name = yandex_compute_instance.platform.name
            nat_ip        = yandex_compute_instance.platform.network_interface.0.nat_ip_address
            fqdn          = yandex_compute_instance.platform.fqdn
        }
        vm_db = {
            instance_name = yandex_compute_instance.platform_db.name
            nat_ip        = yandex_compute_instance.platform_db.network_interface.0.nat_ip_address
            fqdn          = yandex_compute_instance.platform_db.fqdn
        }
    }
}