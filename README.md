# Домашнее задание к занятию «Основы Terraform. Yandex Cloud»

### Задание 1
В качестве ответа всегда полностью прикладывайте ваш terraform-код в git.
Убедитесь что ваша версия **Terraform** ~>1.12.0

1. Изучите проект. В файле variables.tf объявлены переменные для Yandex provider.
2. Создайте сервисный аккаунт и ключ. [service_account_key_file](https://terraform-provider.yandexcloud.net).
4. Сгенерируйте новый или используйте свой текущий ssh-ключ. Запишите его открытую(public) часть в переменную **vms_ssh_public_root_key**.
5. Инициализируйте проект, выполните код. Исправьте намеренно допущенные синтаксические ошибки. Ищите внимательно, посимвольно. Ответьте, в чём заключается их суть.

### Ответ:

Найдены следующие ошибки:

  1. Не были указаны переменные cloud_id и folder_id
  2. Неправильно указан параметр platform_id, standart_v4 допущена лексическая ошибка. Платформа standard_v4 не была найдена, можно изменить на standard_v1 (процессор Intel Broadwell), standard_v2 (Intel Cascade Lake), standard_v3 (Intel Ice Lake) или standard_v4a (AMD Zen 4)
  3. Неправильно указан параметр core_fraction - допустимые значения для платформы standard_v4a 20, 50 или 100 (гарантированная доля vCPU, %)
  4. Неправильно указан параметр cores - допустимые значения 2 или 4 (количество vCPU)

5. Подключитесь к консоли ВМ через ssh и выполните команду ``` curl ifconfig.me```.
Примечание: К OS ubuntu "out of a box, те из коробки" необходимо подключаться под пользователем ubuntu: ```"ssh ubuntu@vm_ip_address"```. Предварительно убедитесь, что ваш ключ добавлен в ssh-агент: ```eval $(ssh-agent) && ssh-add``` Вы познакомитесь с тем как при создании ВМ создать своего пользователя в блоке metadata в следующей лекции.;

### Ответ:

Скриншот ЛК Yandex Cloud:

![1-6.1](https://github.com/murtazinilyas/ter_basics/blob/main/screenshots/t1-6.1.png)

Вывод команды ``` curl ifconfig.me```:

![t1-6.2](https://github.com/murtazinilyas/ter_basics/blob/main/screenshots/t1-6.2.png)

7. Ответьте, как в процессе обучения могут пригодиться параметры ```preemptible = true``` и ```core_fraction=5``` в параметрах ВМ.

### Ответ:

Параметр ```preemptible = true``` и минимально возможное значение параметра ```core_fraction``` позволяют потреблять минимальное количество денежных ресурсов и минимизировать потери, если студент забыл дропнуть ВМ после выполнения домашнего задания.

### Задание 2

1. Замените все хардкод-**значения** для ресурсов **yandex_compute_image** и **yandex_compute_instance** на **отдельные** переменные. К названиям переменных ВМ добавьте в начало префикс **vm_web_** .  Пример: **vm_web_name**.
2. Объявите нужные переменные в файле variables.tf, обязательно указывайте тип переменной. Заполните их **default** прежними значениями из main.tf. 
3. Проверьте terraform plan. Изменений быть не должно. 

### Ответ:

![t2](https://github.com/murtazinilyas/ter_basics/blob/main/screenshots/t2.png)

### Задание 3

1. Создайте в корне проекта файл 'vms_platform.tf' . Перенесите в него все переменные первой ВМ.
2. Скопируйте блок ресурса и создайте с его помощью вторую ВМ в файле main.tf: **"netology-develop-platform-db"** ,  ```cores  = 2, memory = 2, core_fraction = 20```. Объявите её переменные с префиксом **vm_db_** в том же файле ('vms_platform.tf').  ВМ должна работать в зоне "ru-central1-b"
3. Примените изменения.

### Ответ:

Для того, чтобы создать ВМ в другой зоне доступности, необходимо создать также новую подсеть в этой зоне. Объявил переменные в файле 'vms_platform.tf' и добавил блок ресурса **"netology-develop-platform-db"** в файле 'main.tf'.

Файл с переменными 'vms_platform.tf':

```hcl
variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
}

variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v4a"
}

variable "vm_db_resources" {
  type = map(number)
  default = {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
}

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
```

Часть кода из 'main.tf' для создания ВМ **"netology-develop-platform-db"**:

```hcl
resource "yandex_vpc_subnet" "db" {
  name           = var.vm_db_vpc_name
  zone           = var.vm_db_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.vm_db_cidr
}

resource "yandex_compute_instance" "platform_db" {
  name        = var.vm_db_name
  platform_id = var.vm_db_platform_id
  zone        = var.vm_db_zone
  resources {
    cores         = var.vm_db_resources.cores
    memory        = var.vm_db_resources.memory
    core_fraction = var.vm_db_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.db.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}
```

Скриншот ЛК Yandex Cloud'а где видно, что созданная машина находится в зоне доступности ru-central1-b:

![3](https://github.com/murtazinilyas/ter_basics/blob/main/screenshots/t3.png)

### Задание 4

1. Объявите в файле outputs.tf **один** output , содержащий: instance_name, external_ip, fqdn для каждой из ВМ в удобном лично для вас формате.(без хардкода!!!)
2. Примените изменения.

В качестве решения приложите вывод значений ip-адресов команды ```terraform output```.

### Ответ:

![4](https://github.com/murtazinilyas/ter_basics/blob/main/screenshots/t4.png)

### Задание 5

1. В файле locals.tf опишите в **одном** local-блоке имя каждой ВМ, используйте интерполяцию ${..} с НЕСКОЛЬКИМИ переменными по примеру из лекции.
2. Замените переменные внутри ресурса ВМ на созданные вами local-переменные.
3. Примените изменения.

### Ответ:

Создал 'locals.tf', описал в нем следующие переменные:

```hcl
locals {
  project     = "develop-platform"
  env1        = "web"
  env2        = "db"
  vm_web_name = "netology-${local.project}-${local.env1}"
  vm_db_name  = "netology-${local.project}-${local.env2}"
}
```

Заменил в 'main.tf' переменные из 'variables.tf' и 'vms_platform.tf' на local-переменные:

```hcl
...
resource "yandex_compute_instance" "platform" {
  name        = local.vm_web_name
...
resource "yandex_compute_instance" "platform_db" {
  name        = local.vm_db_name
```

Результат выполнения команды 'terraform apply':

![5](https://github.com/murtazinilyas/ter_basics/blob/main/screenshots/t5.png)

### Задание 6

1. Вместо использования трёх переменных  ".._cores",".._memory",".._core_fraction" в блоке  resources {...}, объедините их в единую map-переменную **vms_resources** и  внутри неё конфиги обеих ВМ в виде вложенного map(object).  
   ```
   пример из terraform.tfvars:
   vms_resources = {
     web={
       cores=2
       memory=2
       core_fraction=5
       hdd_size=10
       hdd_type="network-hdd"
       ...
     },
     db= {
       cores=2
       memory=4
       core_fraction=20
       hdd_size=10
       hdd_type="network-ssd"
       ...
     }
   }
   ```
3. Создайте и используйте отдельную map(object) переменную для блока metadata, она должна быть общая для всех ваших ВМ.
   ```
   пример из terraform.tfvars:
   metadata = {
     serial-port-enable = 1
     ssh-keys           = "ubuntu:ssh-ed25519 AAAAC..."
   }
   ```  
  
5. Найдите и закоментируйте все, более не используемые переменные проекта.
6. Проверьте terraform plan. Изменений быть не должно.

### Ответ:

В файл 'variables.tf' добавил следующие переменные:

```hcl
variable "vm_resources" {
  type = map(any)
  default = {
    web = {
    cores         = 2
    memory        = 1
    core_fraction = 20
    }
    db = {
    cores         = 2
    memory        = 2
    core_fraction = 20
    }
  }
}

variable "metadata" {
  type = map(string)
  default = {
    serial-port-enable = 1
    ssh-keys = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILSToR3JR5gmXkTtgSvCezhJDOxkcG2H02REWf1WZye7 ilyas-murtazin@mia-vb"
  }
}
```

Закомментировал следующие переменные в файле 'variables.tf':

```hcl
# variable "vm_web_name" {
#   type        = string
#   default = "netology-develop-platform-web"
# }
# variable "vm_web_resources" {
#   type = map(number)
#   default = {
#     cores         = 2
#     memory        = 1
#     core_fraction = 20
#   }
# }
# variable "vms_ssh_root_key" {
#   type        = string
#   default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILSToR3JR5gmXkTtgSvCezhJDOxkcG2H02REWf1WZye7 ilyas-murtazin@mia-vb"
#   description = "ssh-keygen -t ed25519"
# }
```

Закомментировал следующие переменные в файле 'vms_platform.tf':

```hcl
# variable "vm_db_name" {
#   type        = string
#   default     = "netology-develop-platform-db"
# }
# variable "vm_db_resources" {
#   type = map(number)
#   default = {
#     cores         = 2
#     memory        = 2
#     core_fraction = 20
#   }
# }
```

Вывод команды 'terrform plan':

![6](https://github.com/murtazinilyas/ter_basics/blob/main/screenshots/t6.png)

### Задание 7*

Изучите содержимое файла console.tf. Откройте terraform console, выполните следующие задания: 

1. Напишите, какой командой можно отобразить **второй** элемент списка test_list.

### Ответ:

`local.test_list.1`

2. Найдите длину списка test_list с помощью функции length(<имя переменной>).

### Ответ:

Длина списка test_list равна **3**

3. Напишите, какой командой можно отобразить значение ключа admin из map test_map.

### Ответ:

`local.test_map.admin`

4. Напишите interpolation-выражение, результатом которого будет: "John is admin for production server based on OS ubuntu-20-04 with X vcpu, Y ram and Z virtual disks", используйте данные из переменных test_list, test_map, servers и функцию length() для подстановки значений.

**Примечание**: если не догадаетесь как вычленить слово "admin", погуглите: "terraform get keys of map"

### Ответ:

Выражение получилось следующее:
```
"${local.test_map.admin} is ${keys(local.test_map).0} for ${local.test_list[length(local.test_list)-1]} server based on OS ${local.servers[local.test_list[length(local.test_list)-1]].image} with ${local.servers[local.test_list[length(local.test_list)-1]].cpu} vcpu, ${local.servers[local.test_list[length(local.test_list)-1]].ram} ram and ${length(local.servers[local.test_list[length(local.test_list)-1]].disks)} virtual disks"
```

Вывод всех введенных команд:

![7](https://github.com/murtazinilyas/ter_basics/blob/main/screenshots/t7.png)

------

### Задание 8*
1. Напишите и проверьте переменную test и полное описание ее type в соответствии со значением из terraform.tfvars:
```
test = [
  {
    "dev1" = [
      "ssh -o 'StrictHostKeyChecking=no' ubuntu@62.84.124.117",
      "10.0.1.7",
    ]
  },
  {
    "dev2" = [
      "ssh -o 'StrictHostKeyChecking=no' ubuntu@84.252.140.88",
      "10.0.2.29",
    ]
  },
  {
    "prod1" = [
      "ssh -o 'StrictHostKeyChecking=no' ubuntu@51.250.2.101",
      "10.0.1.30",
    ]
  },
]
```

### Ответ:

```
> type(local.test)
tuple([
    object({
        dev1: tuple([
            string,
            string,
        ]),
    }),
    object({
        dev2: tuple([
            string,
            string,
        ]),
    }),
    object({
        prod1: tuple([
            string,
            string,
        ]),
    }),
])
```

2. Напишите выражение в terraform console, которое позволит вычленить строку "ssh -o 'StrictHostKeyChecking=no' ubuntu@62.84.124.117" из этой переменной.

### Ответ:

Чтобы вычленить необходимую сроку ввел команду `local.test.0.dev1.0`:

![8](https://github.com/murtazinilyas/ter_basics/blob/main/screenshots/t8.png)

------

### Задание 9*

Используя инструкцию https://cloud.yandex.ru/ru/docs/vpc/operations/create-nat-gateway#tf_1, настройте для ваших ВМ nat_gateway. Для проверки уберите внешний IP адрес (nat=false) у ваших ВМ и проверьте доступ в интернет с ВМ, подключившись к ней через serial console. Для подключения предварительно через ssh измените пароль пользователя: ```sudo passwd ubuntu```

### Ответ:

Вывел описание сетей из 'main.tf' в 'networks.tf' и добавил блоки nat_gateway. Получился такой файл:

```hcl
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "db" {
  name           = var.vm_db_vpc_name
  zone           = var.vm_db_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.vm_db_cidr
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = var.vpc_name
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = var.vpc_name
  network_id = yandex_vpc_network.develop.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}
```

Предварительно поменял пароли на обеих машинах, выполнил команду 'terraform apply', зашел в серийную консоль обеих машин, выполнил команды `ip a` и `ping 8.8.8.8`:

![9-1](https://github.com/murtazinilyas/ter_basics/blob/main/screenshots/t9-1.png)

![9-2](https://github.com/murtazinilyas/ter_basics/blob/main/screenshots/t9-2.png)
