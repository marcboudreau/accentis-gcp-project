terraform {
  required_version = "~> 0.14"

  required_providers {
      google = {
          version = ">= 3.61.0"
          source  = "hashicorp/google"
      }
  }

  backend "remote" {
      hostname = "app.terraform.io"
      organization = "accentis"

      workspaces {
          prefix = "project"
      }
  }
}

locals {
    services = [
        "cloudkms.googleapis.com",
    ]
}

resource "google_project_service" "apis" {
    for_each = local.services

    service = each.key
}

data "google_project" "main" {}

resource "google_kms_key_ring" "keys" {
    name = "${data.google_project.main.project_id}-keyring"
    location = "us"
}

resource "google_kms_crypto_key" "disks" {
    name = "disk-encryption"
    key_ring = google_kms_key_ring.keys.id
    purpose = "ENCRYPT_DECRYPT"
}
