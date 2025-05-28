resource "aws_ses_domain_identity" "gitlab_email" {
  domain = var.email_domain
}

resource "aws_ses_domain_dkim" "gitlab_dkim" {
  domain = aws_ses_domain_identity.gitlab_email.domain
}

resource "aws_iam_user" "ses_user" {
  name = "${var.environment}-gitlab-ses-user"
}

resource "aws_iam_access_key" "ses_user" {
  user = aws_iam_user.ses_user.name
}

resource "aws_iam_user_policy" "ses_policy" {
  name = "${var.environment}-gitlab-ses-policy"
  user = aws_iam_user.ses_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendRawEmail",
          "ses:SendEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

# DNS records
resource "aws_route53_record" "ses_verification" {
  zone_id = var.route53_zone_id
  name    = "_amazonses.${var.email_domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.gitlab_email.verification_token]
}

resource "aws_route53_record" "dkim" {
  count   = 3
  zone_id = var.route53_zone_id
  name    = "${element(aws_ses_domain_dkim.gitlab_dkim.dkim_tokens, count.index)}._domainkey.${var.email_domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.gitlab_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}
