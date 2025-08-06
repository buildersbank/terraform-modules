variable "ebs_encryption" {
  description = "EBS default encryption configuration"
  type        = bool
  default     = true
}

variable "ebs_block_public_access" {
  description = "EBS block public access status"
  type        = string
  default     = "block-all-sharing"

  validation {
    condition     = contains(["block-all-sharing", "block-new-sharing"], var.ebs_block_public_access)
    error_message = "Valid values: \"block-all-sharing\" or \"block-new-sharing\"."
  }
}
