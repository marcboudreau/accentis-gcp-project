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

resource "google_service_account" "gke_cluster_module" {
    account_id   = "gke-cluster-module"
    display_name = "gke-cluster-module"
}

resource "google_project_iam_custom_role" "gke_cluster_module" {
  role_id = "gke_cluster_module"
  title   = "gke-cluster-module"
  stage   = "GA"

  permissions = [
    "compute.disks.create",

    "compute.firewalls.create",
    "compute.firewalls.delete",
    "compute.firewalls.get",

    "compute.healthChecks.create",
    "compute.healthChecks.delete",
    "compute.healthChecks.get",
    "compute.healthChecks.use",

    "compute.images.getFromFamily",

    "compute.instanceGroupManagers.create",
    "compute.instanceGroupManagers.delete",
    "compute.instanceGroupManagers.get",
    "compute.instanceGroupManagers.update",

    "compute.instances.create",
    "compute.instances.get",
    "compute.instances.setMetadata",
    "compute.instances.setTags",

    "compute.instanceTemplates.create",
    "compute.instanceTemplates.delete",
    "compute.instanceTemplates.get",
    "compute.instanceTemplates.useReadOnly",

    "compute.networks.create",
    "compute.networks.delete",
    "compute.networks.get",
    "compute.networks.updatePolicy",

    "compute.projects.get",

    "compute.routers.create",
    "compute.routers.delete",
    "compute.routers.get",
    "compute.routers.update",

    "compute.subnetworks.create",
    "compute.subnetworks.delete",
    "compute.subnetworks.get",
    "compute.subnetworks.use",
    "compute.subnetworks.useExternalIp",

    "container.clusters.create",
    "container.clusters.delete",
    "container.clusters.get",
    "container.clusters.update",

    "container.nodes.list",

    "container.operations.get",

    "iam.serviceAccounts.create",
    "iam.serviceAccounts.delete",
    "iam.serviceAccounts.get",
  ]
}

resource "google_project_iam_binding" "gke_cluster_module" {
  role = google_project_iam_custom_role.gke_cluster_module.id

  members = [ 
    "serviceAccount:${google_service_account.gke_cluster_module.email}",
  ]
}

resource "google_service_account_iam_binding" "default_compute_engine" {
  service_account_id = "projects/accentis-288921/serviceAccounts/521113983161-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${google_service_account.gke_cluster_module.email}",
  ]
}

resource "google_service_account" "common_gke_worker_node" {
  account_id = "common-gke-worker-node"
  display_name = "Common GKE Worker Node"
}

resource "google_service_account_iam_binding" "common_gke_worker_node" {
  service_account_id = google_service_account.common_gke_worker_node.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${google_service_account.gke_cluster_module.email}"
  ]
}