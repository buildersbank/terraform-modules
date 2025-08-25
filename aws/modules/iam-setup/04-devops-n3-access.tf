resource "aws_iam_policy" "devops_n3_access_policy" {
  name        = var.devops_n3_policy_name
  description = ""
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowedDevopsAccessN3"
        Effect = "Allow"
        Action = [
          "iam:*",
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
        ]
        Resource = "*"
      }
    ]
  })
}

output "devops_n3_policy_arn" {
  description = "ARN da policy DevOps N3"
  value       = aws_iam_policy.devops_n3_access_policy.arn
}
