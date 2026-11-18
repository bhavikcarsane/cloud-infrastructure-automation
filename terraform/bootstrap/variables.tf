variable "aws_region" {
  description = "AWS region used for Project 1"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "kloudbuild"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}


variable "github_org" {
  description = "GitHub organization or username that owns the repository"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository allowed to assume the Terraform automation role"
  type        = string
}
