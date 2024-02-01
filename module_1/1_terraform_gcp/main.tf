terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.14.0"
    }
  }
}

provider "google" {
  project = "striking-audio-412822"
  region  = "us-central1"
}

resource "google_storage_bucket" "dezc24-bucket" {
  name          = "dezc24-bucket-412822"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}