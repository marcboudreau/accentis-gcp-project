################################################################################
#
# accentis-gcp-project
#   A Terraform project that configures a Google Cloud Platform Project in order
#   to run Accentis deployments.
#
# variables.tf
#   Defines the input variables for the project.
#
################################################################################

variable "project_id" {
    description = "The GCP project ID"
    type        = string
}

variable "default_compute_engine_service_account" {
    description = "The email address of the Compute Engine default service account."
    type        = string
}
