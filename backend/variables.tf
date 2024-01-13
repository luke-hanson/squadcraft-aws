variable backend_id {
  type        = string
  default     = ""
  description = "ID of unique resources used for the terraform backend. If left blank, a random string will be used."
}

variable shared_credentials_files {
  type        = list(string)
  default     = ["~/.aws/credentials"]
  description = "List of file paths from which to pull AWS credentials."
}