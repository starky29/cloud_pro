resource "yandex_compute_instance_group" "ig-1" {
  name                = "balancer"
  folder_id           = var.folder_id
  service_account_id  = yandex_iam_service_account.md-gvm.id
  deletion_protection = false
  instance_template {
    platform_id = "standard-v1"
    resources {
      cores         = 2
      memory        = 2
      core_fraction = 20

    }
    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
      }
    }

    network_interface {
      network_id = yandex_vpc_network.VPC.id
      subnet_ids = ["${yandex_vpc_subnet.public.id}"]
    }

    metadata = {
      user-data = "#!/bin/bash\n cd /var/www/html\n echo \"<html><h1>Load balanced server</h1><img src='https://${yandex_storage_bucket.my_bucket.bucket_domain_name}/${yandex_storage_object.picture.key}'></html>\" > index.html"
      ssh-keys = "starky:${local.ssh_key}"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.default_zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }
  health_check {
    interval = 30
    timeout  = 10
    tcp_options {
      port = 80
    }
  }
  load_balancer {
    target_group_name        = "target-group"
    target_group_description = "Целевая группа Load Balancer"
  }
}

resource "yandex_lb_network_load_balancer" "lb-1" {
  name = "network-load-balancer-1"

  listener {
    name = "network-load-balancer-1-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.ig-1.load_balancer.0.target_group_id

    healthcheck {
      name                = "http"
      interval            = 2
      timeout             = 1
      unhealthy_threshold = 2
      healthy_threshold   = 5
      http_options {
        port = 80
        path = "/index.html"
      }
    }
  }
}