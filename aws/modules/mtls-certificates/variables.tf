variable "ca_config" {
  description = "Configuration for the Certificate Authority"
  type = object({
    common_name         = string
    organization        = string
    organizational_unit = string
    country             = string
    state               = string
    locality            = string
    validity_days       = number
  })
  
  validation {
    condition     = var.ca_config.validity_days > 0
    error_message = "CA validity days must be greater than 0."
  }
}

variable "ca_key_algorithm" {
  description = "Algorithm for CA private key"
  type        = string
  default     = "RSA"
  
  validation {
    condition     = contains(["RSA", "ECDSA"], var.ca_key_algorithm)
    error_message = "CA key algorithm must be RSA or ECDSA."
  }
}

variable "ca_key_size" {
  description = "Size of CA private key (RSA bits)"
  type        = number
  default     = 4096
  
  validation {
    condition     = contains([2048, 3072, 4096], var.ca_key_size)
    error_message = "CA key size must be 2048, 3072, or 4096."
  }
}


variable "client_certificates" {
  description = "List of client certificates to generate"
  type = list(object({
    name          = string
    common_name   = string
    validity_days = number
    dns_names     = optional(list(string), [])
  }))
  
  validation {
    condition     = length(var.client_certificates) > 0
    error_message = "At least one client certificate must be specified."
  }
}

variable "client_key_algorithm" {
  description = "Algorithm for client private keys"
  type        = string
  default     = "RSA"
  
  validation {
    condition     = contains(["RSA", "ECDSA"], var.client_key_algorithm)
    error_message = "Client key algorithm must be RSA or ECDSA."
  }
}

variable "client_key_size" {
  description = "Size of client private keys (RSA bits)"
  type        = number
  default     = 2048
  
  validation {
    condition     = contains([2048, 3072, 4096], var.client_key_size)
    error_message = "Client key size must be 2048, 3072, or 4096."
  }
}


variable "trust_store_bucket" {
  description = "S3 bucket name for trust store"
  type        = string
}

variable "trust_store_ca_key" {
  description = "S3 key for CA certificate in trust store"
  type        = string
  default     = "ca/ca-certificate.pem"
}

variable "create_trust_store_bucket" {
  description = "Whether to create the trust store S3 bucket"
  type        = bool
  default     = true
}

variable "output_path" {
  description = "Local path to save certificates"
  type        = string
  default     = "./certificates"
}

variable "environment" {
  description = "Environment name"
  type        = string
}
