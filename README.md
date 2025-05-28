# Self-hosted Gitlab

## Description


## Requirements

* AWS cli - ensure your system has `awscli` configured
* Docker
* Terraform
  * recommend to use [tfswitch](https://tfswitch.warrensbox.com/Installation/) as TF version is pinned 

### The secrets file
create a `terraform.tfvars` secret file and make sure you add it to `.gitignore`. DO NOT COMMIT THIS FILE

```
aws_region        = "ap-southeast-1" # or your preferred region
route53_zone_id   = "XXXXXXXXXXXXXXXXXX"
email_domain      = "example.com"
ses_smtp_username = "AXXXXXXXXXXXXXXXXXXN"                         # From AWS SES SMTP credentials
ses_smtp_password = "BXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX5" # From AWS SES SMTP credentials
```

## Setting Up
```
terraform init
terraform apply
```

Wait a few moments, then instance should be exposed at http://localhost:8080
