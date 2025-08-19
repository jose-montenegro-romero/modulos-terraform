output "all_unique_paths" {
  value = local.all_unique_paths
}

output "root_resources" {
  value = local.root_resources
}

output "child_resources" {
  value = local.child_resources
}

output "apigateway_stage_reference" {
  value = aws_api_gateway_stage.api_gateway_stage
}