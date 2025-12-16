resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "dynamodb-${var.configuration_dynamodb.name}-${var.project}-${var.environment}"
  
  # Modo de Facturación dinámico (por defecto es PAY_PER_REQUEST)
  billing_mode   = var.configuration_dynamodb.billing_mode
  
  # Claves
  hash_key       = var.configuration_dynamodb.hash_key
  range_key      = var.configuration_dynamodb.range_key

  # Bloques de capacidad condicionales:
  # Solo se incluyen si el billing_mode es "PROVISIONED"
  # y los valores de capacidad han sido definidos.

  # Capacidad de lectura
  read_capacity  = var.configuration_dynamodb.billing_mode == "PROVISIONED" ? (
    # Si es PROVISIONED, usamos el valor provisto o un valor por defecto (ej. 5)
    lookup(var.configuration_dynamodb, "read_capacity", 5)
  ) : null # Si es PAY_PER_REQUEST, debe ser null

  # Capacidad de escritura
  write_capacity = var.configuration_dynamodb.billing_mode == "PROVISIONED" ? (
    # Si es PROVISIONED, usamos el valor provisto o un valor por defecto (ej. 5)
    lookup(var.configuration_dynamodb, "write_capacity", 5)
  ) : null # Si es PAY_PER_REQUEST, debe ser null


  # 1. Atributos
  for_each = var.configuration_dynamodb.attributes
  attribute {
    name = each.key
    type = each.value
  }

  # 2. TTL
  dynamic "ttl" {
    for_each = var.configuration_dynamodb.ttl_attribute_name != null ? [1] : []

    content {
      attribute_name = var.configuration_dynamodb.ttl_attribute_name
      enabled        = true
    }
  }

  # 3. Índices Secundarios Globales (GSI) - También deben ser dinámicos en su capacidad
  dynamic "global_secondary_index" {
    for_each = var.configuration_dynamodb.global_secondary_indexes
    content {
      name               = global_secondary_index.key
      hash_key           = global_secondary_index.value.hash_key
      range_key          = global_secondary_index.value.range_key
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      
      # Los índices deben especificar capacidad, incluso en modo On-Demand 
      # (aunque sólo se usa en PROVISIONED, DynamoDB requiere los campos).
      # Los usaremos tal cual están definidos en la variable.
      write_capacity     = global_secondary_index.value.write_capacity
      read_capacity      = global_secondary_index.value.read_capacity
    }
  }

  tags = merge(var.tags, {
    Name        = "dynamodb-${var.configuration_dynamodb.name}-${var.project}-${var.environment}"
    Environment = var.environment
    Source      = "Terraform"
  })
}