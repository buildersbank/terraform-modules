# Outputs do módulo External Secrets
output "external_secrets_role_arn" {
  description = "ARN da role IAM para External Secrets"
  value       = aws_iam_role.external_secrets_role.arn
  sensitive   = false
}

output "external_secrets_role_name" {
  description = "Nome da role IAM para External Secrets"
  value       = aws_iam_role.external_secrets_role.name
  sensitive   = false
}

output "external_secrets_policy_arn" {
  description = "ARN da política IAM para External Secrets"
  value       = module.amazon-external-secret-policy.arn
  sensitive   = false
}

output "cluster_secret_store_name" {
  description = "Nome do ClusterSecretStore criado"
  value       = "aws-secretsmanager"
  sensitive   = false
}
