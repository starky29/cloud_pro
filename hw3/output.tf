output "backet" {
  value = yandex_storage_bucket.my_bucket.bucket_domain_name
}

output "picture_key" {
  value = yandex_storage_object.picture.key
}