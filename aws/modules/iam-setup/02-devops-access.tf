resource "aws_iam_policy" "devops_access_policy" {
  name        = var.devops_policy_name
  description = ""
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowedDevopsAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:*",
          "s3:*",
          "waf:*",
          "wafv2:*",
          "mq:*",
          "ec2:*",
          "eks:*",
          "elasticache:*",
          "billing:*",
          "cur:*",
          "ce:*",
          "acm:*",
          "ses:*",
          "route53:*",
          "cloudfront:*",
          "elasticloadbalancing:*",
          "logs:*",
          "cloudwatch:*",
          "kms:*",
          "support:*",
          "sns:*",
          "msk:*",
          "kafka:*",
        ]
        Resource = "*"
      },
    ]
  })
}

output "devops_policy_arn" {
  description = "ARN da policy DevOps"
  value       = aws_iam_policy.devops_access_policy.arn
}
