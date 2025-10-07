module "amazon-external-secret-policy" {
  source = "github.com/buildersbank/terraform-modules/aws/modules/iam_policy"

  name        = "ExternalSecretPolicy"
  description = "ExternalSecretPolicy"

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action" : [
            "secretsmanager:ListSecrets",
            "secretsmanager:BatchGetSecretValue"
          ],
          "Effect" : "Allow",
          "Resource" : "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds"
          ],
          "Resource": [
            "*"
          ]
        }
      ]
    }
  )
}

# Role IAM para External Secrets
resource "aws_iam_role" "external_secrets_role" {
  name = "${var.cluster_name}-external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_arn, "/^.*oidc-provider\\//", "")}:sub" = "system:serviceaccount:external-secrets:external-secrets"
            "${replace(var.oidc_provider_arn, "/^.*oidc-provider\\//", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Anexar política à role
resource "aws_iam_role_policy_attachment" "external_secrets_policy_attachment" {
  role       = aws_iam_role.external_secrets_role.name
  policy_arn = module.amazon-external-secret-policy.arn
}