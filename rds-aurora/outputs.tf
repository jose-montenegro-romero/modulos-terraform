# outputs.tf
output "rds_reference" {
  value = aws_rds_cluster.rds_cluster
}

output "rds_master_secret_id" {
  description = "The ID of the Secrets Manager secret storing the RDS master user password."
  value       = lookup(var.configuration_rds, "manage_master_user_password", true) == true ? aws_rds_cluster.rds_cluster.master_user_secret[0].secret_arn : ""
}
