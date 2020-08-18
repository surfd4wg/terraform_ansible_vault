variable "public_key_path" {
  description = "Path to the public SSH key you want to bake into the instance."
  default     = "~/.ssh/ubuntu.pub"
}

variable "private_key_path" {
  description = "Path to the private SSH key, used to access the instance."
  default     = "~/.ssh/ubuntu"
}

variable "project_name" {
  description = "SurfD4wgs terraform VAULT aws DEMO"
  default     = "terraformVAULTaws"
}

variable "ssh_user" {
  description = "SSH user name to connect to your instance."
  default     = "ubuntu"
}

variable "access_key" {
    description = "Access Key to AWS account"
    default = "xxxx"
}

variable "secret_key" {
    description = "Access Secret Key to AWS account"
    default = "xxxxx"
}
