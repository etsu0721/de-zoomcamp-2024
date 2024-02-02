variable "credentials" {
  description = "Credentials authenticating Terraform to GCP"
  default     = "./keys/creds.json"
}

variable "project_id" {
  description = "Project ID"
  default     = "striking-audio-412822"
}

variable "location" {
  description = "Project Location"
  default     = "US"
}

variable "region" {
  description = "Project Region"
  default     = "us-central1"
}

variable "bq_dataset_id" {
  description = "BigQuery Dataset ID"
  default     = "dezc24_dataset"
}

variable "gcs_bucket_id" {
  description = "Storage Bucket ID"
  default     = "dezc24-bucket-412822"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}