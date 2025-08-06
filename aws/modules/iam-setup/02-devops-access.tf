resource "aws_iam_policy" "devops_access_policy" {
  name        = "AllowedDevopsAccess"
  description = ""
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VisualEditor0"
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
          "ses:*"
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
