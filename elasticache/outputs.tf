output "elasticache_reference" {
  description = "Referencia del servicio creado para elasticache"
  value       = aws_elasticache_serverless_cache.elasticache_serverless_cache
}
