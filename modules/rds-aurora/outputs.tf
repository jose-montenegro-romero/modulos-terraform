# outputs.tf
output "rds_reference" {
  value = aws_rds_cluster.db
}
