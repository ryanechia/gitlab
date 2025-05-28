variable "gitlab_external_url" {
  description = "The external URL for the GitLab instance (e.g., http://localhost:8080 or http://your_domain.com)"
  type        = string
  default     = "http://localhost:8080"
}


variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 Hosted Zone ID"
  type        = string
}

variable "email_domain" {
  description = "Domain name for email services"
  type        = string
}

variable "ses_smtp_username" {
  description = "AWS SES SMTP username"
  type        = string
  sensitive   = true
}

variable "ses_smtp_password" {
  description = "AWS SES SMTP password"
  type        = string
  sensitive   = true
}
