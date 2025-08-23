resource "aws_iam_policy" "deny_confidential_secrets" {
  name        = var.deny_confidential_secrets_policy_name
  description = ""
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyGetSecretValueForEnvConfidential"
        Effect = "Deny"
        Action = "secretsmanager:*"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/confidential" = "true"
          }
        }
      }
    ]
  })
}

output "deny_confidential_secrets_policy_arn" {
  description = "ARN da policy que nega acesso a secrets confidenciais"
  value       = aws_iam_policy.deny_confidential_secrets.arn
}
