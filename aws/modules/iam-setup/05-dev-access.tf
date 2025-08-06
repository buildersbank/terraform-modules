resource "aws_iam_policy" "dev_access_policy" {
  name        = "AllowedDevAccess"
  description = "Policy com permissões específicas do EKS para ambientes de produção"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListAccessPointsForObjectLambda",
          "eks:ListEksAnywhereSubscriptions",
          "eks:DescribeFargateProfile",
          "eks:ListTagsForResource",
          "eks:DescribeInsight",
          "eks:ListAccessEntries",
          "eks:ListAddons",
          "s3:PutStorageLensConfiguration",
          "s3:ListStorageLensGroups",
          "eks:DescribeEksAnywhereSubscription",
          "eks:DescribeAddon",
          "eks:ListAssociatedAccessPolicies",
          "eks:DescribeNodegroup",
          "s3:ListAccessGrantsInstances",
          "eks:ListUpdates",
          "eks:DescribeAddonVersions",
          "eks:ListIdentityProviderConfigs",
          "eks:ListNodegroups",
          "eks:DescribeAddonConfiguration",
          "s3:ListAccessPoints",
          "s3:ListJobs",
          "s3:CreateStorageLensGroup",
          "s3:ListMultiRegionAccessPoints",
          "eks:DescribeAccessEntry",
          "s3:ListStorageLensConfigurations",
          "eks:DescribePodIdentityAssociation",
          "eks:ListInsights",
          "eks:DescribeClusterVersions",
          "eks:ListPodIdentityAssociations",
          "eks:ListFargateProfiles",
          "s3:ListAllMyBuckets",
          "eks:DescribeIdentityProviderConfig",
          "eks:DescribeUpdate",
          "eks:AccessKubernetesApi",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListAccessPolicies",
          "s3:CreateJob",
          "secretsmanager:ListSecrets"
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
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : [
          "s3:DeleteBucketMetadataTableConfiguration",
          "s3:PauseReplication",
          "s3:PutAnalyticsConfiguration",
          "s3:PutAccelerateConfiguration",
          "s3:DeleteObjectVersion",
          "s3:ListBucketVersions",
          "s3:RestoreObject",
          "s3:CreateBucket",
          "s3:ListBucket",
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
        "Sid" : "VisualEditor2",
        "Effect" : "Allow",
        "Action" : "secretsmanager:*",
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
  description = "ARN da policy de acesso EKS para produção"
  value       = aws_iam_policy.dev_access_policy.arn
}
