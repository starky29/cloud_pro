#создаем vpc
resource "yandex_vpc_network" "netology" {
  name = "netology"
}
#считываем данные об образе ОС
data "yandex_compute_image" "ubuntu" {
    family = var.vm_family
}