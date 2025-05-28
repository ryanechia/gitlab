variable "environment" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
}

variable "email_domain" {
  description = "Domain for email services"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 zone ID"
  type        = string
}
