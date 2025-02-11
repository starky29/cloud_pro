#создание сабнет private
resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = var.default_cidr_privat
  route_table_id = yandex_vpc_route_table.route_table.id
}
#создание таблицы маршрутизации и добавление статического маршрута
resource "yandex_vpc_route_table" "route_table" {
  name       = "route_table"
  network_id = yandex_vpc_network.netology.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}

#создание private VM
resource "yandex_compute_instance" "private-vm" {
  name        = "private-vm"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      type     = "network-hdd"
      size     = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = false
  }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = 1
  }
}

data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")

  vars = {
    ssh_public_key     = local.ssh_key
  }
}