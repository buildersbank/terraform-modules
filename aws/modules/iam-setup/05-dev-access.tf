resource "aws_iam_policy" "dev_access_policy" {
  name        = var.dev_policy_name
  description = "Policy com permissões específicas do EKS para ambientes de desenvolvimento e homologação"

  lifecycle {
    ignore_changes = [
      description
    ]
  }

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "GlobalEKSActions",
        "Effect" : "Allow",
        "Action" : [
          "eks:ListClusters",
          "eks:DescribeClusterVersions",
          "eks:ListEksAnywhereSubscriptions",
          "eks:ListAccessEntries",
          "eks:ListAddons",
          "eks:ListUpdates",
          "eks:DescribeAddonVersions",
          "eks:ListIdentityProviderConfigs",
          "eks:ListNodegroups",
          "eks:ListFargateProfiles",
          "eks:ListInsights",
          "eks:ListPodIdentityAssociations",
          "eks:ListAccessPolicies",
          "eks:ListAssociatedAccessPolicies",
          "secretsmanager:ListSecrets",
          "s3:ListAllMyBuckets",
          "s3:ListBucket"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "ResourceSpecificEKSActions",
        "Effect" : "Allow",
        "Action" : [
          "eks:DescribeFargateProfile",
          "eks:ListTagsForResource",
          "eks:DescribeInsight",
          "eks:DescribeEksAnywhereSubscription",
          "eks:DescribeAddon",
          "eks:DescribeNodegroup",
          "eks:DescribeAddonConfiguration",
          "eks:DescribeAccessEntry",
          "eks:DescribePodIdentityAssociation",
          "eks:DescribeIdentityProviderConfig",
          "eks:DescribeUpdate",
          "eks:AccessKubernetesApi",
          "eks:DescribeCluster"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/environment" : [
              "homolog",
              "develop"
            ]
          }
        }
      },
      {
        "Sid" : "S3BasicActions",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:GetBucketPolicy",
          "s3:GetBucketTagging",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetBucketAcl",
          "s3:GetBucketCORS",
          "s3:GetBucketLogging",
          "s3:GetBucketNotification",
          "s3:GetBucketRequestPayment",
          "s3:GetBucketWebsite",
          "s3:GetBucketObjectLockConfiguration",
          "s3:GetBucketEncryption",
          "s3:GetBucketIntelligentTieringConfiguration",
          "s3:GetBucketAnalyticsConfiguration",
          "s3:GetBucketMetricsConfiguration",
          "s3:GetBucketReplication",
          "s3:GetBucketAccelerateConfiguration",
          "s3:GetBucketInventoryConfiguration",
          "s3:GetBucketLifecycleConfiguration"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "S3Actions",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListAccessPointsForObjectLambda",
          "s3:PutStorageLensConfiguration",
          "s3:ListStorageLensGroups",
          "s3:ListAccessGrantsInstances",
          "s3:ListAccessPoints",
          "s3:ListJobs",
          "s3:CreateStorageLensGroup",
          "s3:ListMultiRegionAccessPoints",
          "s3:ListStorageLensConfigurations",
          "s3:CreateJob",
          "s3:DeleteBucketMetadataTableConfiguration",
          "s3:PauseReplication",
          "s3:PutAnalyticsConfiguration",
          "s3:PutAccelerateConfiguration",
          "s3:DeleteObjectVersion",
          "s3:ListBucketVersions",
          "s3:RestoreObject",
          "s3:CreateBucket",
          "s3:CreateBucketMetadataTableConfiguration",
          "s3:ReplicateObject",
          "s3:PutEncryptionConfiguration",
          "s3:DeleteBucketWebsite",
          "s3:AbortMultipartUpload",
          "s3:PutLifecycleConfiguration",
          "s3:DeleteObject",
          "s3:DeleteBucket",
          "s3:PutBucketVersioning",
          "s3:ListBucketMultipartUploads",
          "s3:PutIntelligentTieringConfiguration",
          "s3:PutMetricsConfiguration",
          "s3:PutReplicationConfiguration",
          "s3:GetObjectAttributes",
          "s3:PutObjectLegalHold",
          "s3:InitiateReplication",
          "s3:PutBucketCORS",
          "s3:PutInventoryConfiguration",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:GetObject",
          "s3:PutBucketNotification",
          "s3:PutBucketWebsite",
          "s3:PutBucketRequestPayment",
          "s3:PutObjectRetention",
          "s3:PutBucketLogging",
          "s3:PutBucketObjectLockConfiguration",
          "s3:ReplicateDelete",
          "s3:GetObjectVersion",
          "s3:UploadPartCopy",
          "s3:UploadPart"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/environment" : [
              "homolog",
              "develop"
            ]
          }
        }
      },
      {
        "Sid" : "SecretsManagerActions",
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:ListSecrets",
          "secretsmanager:*"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/environment" : [
              "homolog",
              "develop"
            ]
          }
        }
      }
    ]
  })
}

output "dev_eks_access_policy_arn" {
  description = "ARN da policy de acesso EKS para desenvolvimento e homologação"
  value       = aws_iam_policy.dev_access_policy.arn
}
