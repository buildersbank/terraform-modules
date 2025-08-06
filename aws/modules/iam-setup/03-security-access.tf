resource "aws_iam_policy" "security_access_policy" {
  name        = "AllowedSecurityAccess"
  description = ""
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid    = "VisualEditor0"
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*",
          "waf:*",
          "wafv2:*",
          "mq:Describe*",
          "mq:List*",
          "ec2:Describe*",
          "ec2:Get*",
          "ec2:List*",
          "ec2:EnableEbsEncryptionByDefault",
          "ec2:EnableSnapshotBlockPublicAccess",
          "eks:Describe*",
          "eks:List*",
          "elasticache:Describe*",
          "elasticache:List*",
          "acm:Describe*",
          "acm:Get*",
          "acm:List*",
          "ses:Get*",
          "ses:List*",
          "guardduty:*",
          "organizations:ListPoliciesForTarget",
          "organizations:DescribeEffectivePolicy",
          "organizations:ListTargetsForPolicy",
          "organizations:DetachPolicy",
          "organizations:DeletePolicy",
          "organizations:DeleteResourcePolicy",
          "organizations:DisablePolicyType",
          "organizations:DescribePolicy",
          "organizations:ListPolicies",
          "organizations:DescribeResourcePolicy",
          "organizations:UpdatePolicy",
          "organizations:EnablePolicyType",
          "organizations:AttachPolicy",
          "organizations:PutResourcePolicy",
          "organizations:CreatePolicy",
          "organizations:ListRoots",
          "organizations:ListDelegatedServicesForAccount",
          "organizations:DescribeAccount",
          "organizations:ListChildren",
          "organizations:ListCreateAccountStatus",
          "organizations:DescribeOrganization",
          "organizations:DescribeOrganizationalUnit",
          "organizations:DescribeHandshake",
          "organizations:DescribeCreateAccountStatus",
          "organizations:ListTagsForResource",
          "organizations:ListAWSServiceAccessForOrganization",
          "organizations:ListDelegatedAdministrators",
          "organizations:ListAccountsForParent",
          "organizations:ListHandshakesForOrganization",
          "organizations:ListHandshakesForAccount",
          "organizations:ListAccounts",
          "organizations:ListParents",
          "organizations:ListOrganizationalUnitsForParent"
        ]
        Resource = "*"
      }
    ], var.bucket_tfstate_arn != "" ? [
      {
        Sid    = "VisualEditor1"
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          var.bucket_tfstate_arn,
          "${var.bucket_tfstate_arn}/*"
        ]
      }
    ] : [])
  })
}

output "security_access_policy_arn" {
  description = "ARN da policy Security"
  value       = aws_iam_policy.security_access_policy.arn
}
