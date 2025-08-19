output "rds_reference"{
    value = aws_db_instance.rds
}

output "password"{
    value = random_password.password.result
}