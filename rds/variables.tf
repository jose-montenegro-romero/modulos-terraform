variable "layer" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "stack_id" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "instances_type" {
  description = "Instances Type for rds"
  default     = "db.t2.micro"
}
variable "vpc_id"{
  description = "vpc for rds"
}
variable "cidr_blocks"{
  description = "sg for rds"
}
variable "multi_az" {
  description = "multi_az for rds"
  default     = false
}
variable "db_name" {
  description = "rds name"
  default     = "mydb1"
}
variable "rds_port" {
  default     = 3306
  description = "Rds port to connect"
}
variable "publicly_accessible" {
  description = "publicly_accessible"
  default     = true # change to false
}
variable "storage_encrypted" {
  description = "storage_encrypted"
  default     = false # chanfe to true
}
variable "user_name" {
  description = "username for database"
  default     = "admin"
}
variable "allocated_storage" {
  description = "storage for rds on GB"
  default     = 5
}
variable "subnet_ids" {
  type = list(string)
  description = "subnet_ids"
}
variable "skip_final_snapshot" {
  description = "skip snapshot when delete rds"
  default     = true # change to false
}

variable "max_allocated_storage"{
  default     = 100
}

variable "deletion_protection" {
  description = "deletion protection for database"
  default     = true
}

variable "performance_insights_enabled" {
  description = "performance insights"
  default     = false
}

variable "identifier"               { }
variable "security_group"           { default = [] }
variable "storage_type"             { default = "gp2" }
variable "engine"                   { default = "mysql" }
variable "engine_version"           { default = "5.7" }
variable "backup_retention_period"  { default = 7 }
variable "family"                   { default = "mysql5.7" }
variable "parameters"               { 
  default = [
    {
      name  = "character_set_server"
      value = "utf8"
    },
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "general_log"
      value = "0"
    }
  ]
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}