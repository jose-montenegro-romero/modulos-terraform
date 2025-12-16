output "dynamodb_reference" {
  description = "Referencia de DynamoDB"
  value       = aws_dynamodb_table.dynamodb_table
}