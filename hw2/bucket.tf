resource "yandex_storage_bucket" "my_bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "starkov-2025-13-02" # Имя бакета
  acl        = "public-read"

}
resource "yandex_storage_object" "picture" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "starkov-2025-13-02"
  key        = "pic.jpg"
  source     = "./pic.jpg"
  acl        = "public-read"
  depends_on = [yandex_storage_bucket.my_bucket]
}