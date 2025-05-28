module "gitlab_email" {
  source = "./modules/email_sender"

  environment     = "prod"
  email_domain    = var.email_domain
  route53_zone_id = var.route53_zone_id
}
