/* environment  */
variable "stack_id" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "layer" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "layer_2" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "aws_region" {
  description = "Region where the infra is displayed"
  type        = string
}

/* BASTION  */

variable "configuration_ec2_bastion" {
  description = "Parameter configuration for creation ec2"
  type        = any
}

/* VPC */
variable "vpc_cidr" {
  description = "CIDR vpc connection red"
  type        = string
}

variable "subnets_public" {
  description = "CIDR subnet public connection red"
  type        = list(string)
}

variable "subnets_private" {
  description = "CIDR subnet private connection red"
  type        = list(string)
}

/* SSM */
variable "ssm_google_recaptcha_hermes" {
  description = "Parameter configuration for ssm"
  type        = any
}

variable "ssm_google_recaptcha_advantage" {
  description = "Parameter configuration for ssm"
  type        = any
}

/* CERTIFICATE MANAGER */
variable "configuration_acm_hermes" {
  description = "Parameter configuration for creation acm"
  type        = any
}

variable "configuration_acm_multimedia_hermes" {
  description = "Parameter configuration for creation acm"
  type        = any
}

variable "configuration_acm_wordpress_advantage" {
  description = "Parameter configuration for creation acm"
  type        = any
}

variable "configuration_acm_backend_advantage" {
  description = "Parameter configuration for creation acm"
  type        = any
}

variable "configuration_acm_multimedia_advantage" {
  description = "Parameter configuration for creation acm"
  type        = any
}

/* CODEPIPELINE  */
variable "configuration_codepipeline_terraform" {
  description = "Parameter configuration for creation codepipeline terraform"
  type        = any
}

variable "configuration_pipeline_front_hermes" {
  description = "Parameter configuration for creation codepipeline front"
  type        = any
}

variable "configuration_pipeline_back_hermes" {
  description = "Parameter configuration for creation codepipeline"
  type        = any
}

variable "configuration_pipeline_wordpress_advantage" {
  description = "Parameter configuration for creation codepipeline"
  type        = any
}

variable "configuration_pipeline_front_advantage" {
  description = "Parameter configuration for creation codepipeline"
  type        = any
}

variable "configuration_pipeline_back_advantage" {
  description = "Parameter configuration for creation codepipeline"
  type        = any
}

/* S3 PageStatic*/
variable "configuration_front_hermes" {
  description = "Parameter configuration for creation s3"
  type        = any
}

variable "configuration_multimedia_hermes" {
  description = "Parameter configuration for creation s3"
  type        = any
}

variable "configuration_front_advantage" {
  description = "Parameter configuration for creation s3"
  type        = any
}

variable "configuration_multimedia_advantage" {
  description = "Parameter configuration for creation s3"
  type        = any
}

/* CLOUDFRONT  */

variable "configuration_cloudfront_front_hermes_oai" {
  description = "Parameter configuration for cloudfront OAI"
  type        = any
}

variable "configuration_cloudfront_front_advantage_oai" {
  description = "Parameter configuration for cloudfront OAI"
  type        = any
}

variable "configuration_cloudfront_front_hermes" {
  description = "Parameter configuration for cloudfront front"
  type        = any
}

variable "configuration_cloudfront_back_hermes" {
  description = "Parameter configuration for cloudfront front"
  type        = any
}

variable "configuration_cloudfront_front_advantage" {
  description = "Parameter configuration for cloudfront front"
  type        = any
}

variable "configuration_cloudfront_back_advantage" {
  description = "Parameter configuration for cloudfront front"
  type        = any
}

/* ECS  */

variable "configuration_ecs_back_hermes" {
  description = "Parameter configuration for creation ecs back"
  type        = any
}

variable "configuration_ecs_wordpress_advantage" {
  description = "Parameter configuration for creation ecs back"
  type        = any
}

variable "configuration_ecs_back_advantage" {
  description = "Parameter configuration for creation ecs back"
  type        = any
}

/* EFS */
variable "configuration_efs_back_hermes" {
  description = "Parameter configuration for creation efs"
  type        = any
}

/* RDS  */
variable "configuration_rds_aurora_mysql_hermes" {
  description = "Parameter configuration for creation RDS"
  type        = any
}

variable "configuration_rds_aurora_mysql_advantage" {
  description = "Parameter configuration for creation RDS"
  type        = any
}

variable "configuration_rds_aurora_mysql_back_advantage" {
  description = "Parameter configuration for creation RDS"
  type        = any
}
