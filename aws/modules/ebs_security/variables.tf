variable "ebs_encryption" {
  description = "EBS default encryption configuration"
  type        = bool
  default     = true
}

variable "ebs_block_public_access" {
  description = "EBS block public access status"
  type        = string
  default     = "block-all-sharing"
}
