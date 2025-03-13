output "efs_file_system_reference" {
  value = aws_efs_file_system.efs_file_system
}

output "efs_access_point_reference" {
  value = aws_efs_access_point.efs_access_point[0]
}

