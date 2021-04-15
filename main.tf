terraform {
  required_version = "~> 0.14"

  required_providers {
      google = {
          version = "~> 3.64"
          source  = "registry.terraform.io/hashicorp/google"
      }
  }

  backend "remote" {
      hostname = "app.terraform.io"
      organization = "accentis"

      workspaces {
          prefix = "accentis-gcp-project-"
      }
  }
}

provider "google" {
    project = var.project_id
}

locals {
    services = [
        "cloudkms.googleapis.com",
        "container.googleapis.com",
    ]
}

resource "google_project_service" "apis" {
    for_each = toset(local.services)

    service = each.key
}

resource "google_kms_key_ring" "keys" {
    name = "${var.project_id}-keyring"
    location = "global"
}

resource "google_kms_crypto_key" "disks" {
    name = "disk-encryption"
    key_ring = google_kms_key_ring.keys.id
    purpose = "ENCRYPT_DECRYPT"
    rotation_period = "7776000s"
}
