resource "yandex_iam_service_account" "service" {
  folder_id = var.folder_id
  name      = "bucket-md"
}
#Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.service.id
  description        = "static access key for object storage"
}
# Назначение роли для сервисного аккаунта
resource "yandex_resourcemanager_folder_iam_member" "bucket-editor" {
  folder_id  = var.folder_id
  role       = "storage.editor"
  member     = "serviceAccount:${yandex_iam_service_account.service.id}"
  depends_on = [yandex_iam_service_account.service]
}
# Сервисный аккаунт для управления группой В
resource "yandex_iam_service_account" "md-gvm" {
  name = "md-gvm"
}
#Назначение роли для сервисного аккаунта
resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.md-gvm.id}"
}
resource "yandex_vpc_network" "VPC" {
  name = "netology"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.VPC.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}