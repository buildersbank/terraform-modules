resource "aws_ebs_snapshot_block_public_access" "snapshot_block_public_acces" {
  state = var.ebs_block_public_access
}

resource "aws_ebs_encryption_by_default" "default_encryption_virginia" {
  enabled = var.ebs_encryption
}