output "smtp_username" {
  value     = aws_iam_access_key.ses_user.id
  sensitive = true
}

output "smtp_password" {
  value     = aws_iam_access_key.ses_user.ses_smtp_password_v4
  sensitive = true
}

output "ses_domain_identity_arn" {
  value = aws_ses_domain_identity.gitlab_email.arn
}
