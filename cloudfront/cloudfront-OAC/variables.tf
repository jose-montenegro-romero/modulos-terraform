variable "project" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "environment" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "name" {
  description = "Nombre para OAC"
  type        = string
}

variable "s3_reference" {
  description = "ARN identifier reference s3"
  type        = any
}

variable "cloudfront_reference" {
  description = "ARN identifier reference cloudfront"
  type        = any
}

variable "origin_access_control_origin_type" {
  description = "El tipo de origen para el cual este Control de Acceso de Origen es aplicable. Los valores válidos son lambda, mediapackagev2, mediastore y s3."
  type        = string
  default     = "s3"

  validation {
    condition     = contains(["s3", "lambda", "mediastore", "mediapackagev2"], var.origin_access_control_origin_type)
    error_message = "El valor debe ser: 's3', 'lambda', 'mediastore' o 'mediapackagev2'."
  }
}

variable "signing_behavior" {
  description = "Especifica qué solicitudes firma CloudFront."
  type        = string
  default     = "always"

  validation {
    condition     = contains(["always", "never", "no-override"], var.signing_behavior)
    error_message = "El valor debe ser: 'always', 'never' o 'no-override'."
  }
}

variable "signing_protocol" {
  description = "Determina cómo CloudFront firma (autentica) las solicitudes."
  type        = string
  default     = "sigv4"

  validation {
    condition     = contains(["sigv4"], var.signing_protocol)
    error_message = "El valor debe ser: 'sigv4'."
  }
}
