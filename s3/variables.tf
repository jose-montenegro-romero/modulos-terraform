variable "project" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "environment" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "custom_name" {
  description = "Nombre para S3 personalizado"
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "Nombre para S3"
  type        = string
  default     = "default"
}

variable "force_destroy" {
  description = "Parameter configuration creation s3"
  type        = bool
  default     = false
}

variable "s3_bucket_ownership_controls_rule" {
  description = "Configuración propietario sobre los objetos"
  type = object({
    object_ownership = string
  })
  default = {
    object_ownership = "BucketOwnerEnforced"
  }

}

variable "s3_bucket_acl" {
  description = "Configuración para acl"
  type = object({
    acl = string
  })
  default = {
    acl = "private"
  }

}

variable "s3_bucket_versioning" {
  description = "Configuración bucket versionamiento"
  type = object({
    status = string
  })
  default = {
    status = "Disabled" //Enabled
  }

}

variable "s3_bucket_website_configuration" {
  description = "Configuración bucket versionamiento"
  type = object({
    index_document_suffix = string
    error_document_key    = string
  })
  nullable = true
  default  = null

}

variable "s3_bucket_public_access_block" {
  description = "Configuración para acceso público"
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
