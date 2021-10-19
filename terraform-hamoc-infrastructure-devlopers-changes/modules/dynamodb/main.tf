##Dynamodb hash/range key locals

locals {
  attributes = concat(
    [
      {
        name = var.range_key
        type = "S"
      },
      {
        name = var.hash_key
        type = "S"
      }
    ],
    var.dynamodb_attributes
  )

  from_index = length(var.range_key) > 0 ? 0 : 1
  attributes_final = slice(local.attributes, local.from_index, length(local.attributes))
}

##Global secondary indexes triggers

resource "null_resource" "global_secondary_indexes" {
  count    = length(var.global_secondary_index_map)

  triggers = {
    "name" = var.global_secondary_index_map[count.index]["name"]
  }
}

##Local secondary indexes triggers

resource "null_resource" "local_secondary_index_names" {
  count = length(var.local_secondary_index_map)

  triggers = {
    "name" = var.local_secondary_index_map[count.index]["name"]
  }
}

##Dynamodb table

resource "aws_dynamodb_table" "default" {
  name           = "${local.prefix}-${var.name}-${local.suffix}"
  billing_mode   = var.billing_mode
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = var.hash_key
  range_key      = var.range_key

  server_side_encryption {
    enabled = var.enable_encryption
  }

  dynamic "attribute" {
    for_each = local.attributes_final
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_index_map
    content {
      hash_key           = global_secondary_index.value.hash_key
      name               = global_secondary_index.value.name
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      projection_type    = global_secondary_index.value.projection_type
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      read_capacity      = lookup(global_secondary_index.value, "read_capacity", null)
      write_capacity     = lookup(global_secondary_index.value, "write_capacity", null)
    }
  }

  ttl {
    attribute_name = var.ttl_attribute
    enabled        = var.ttl_enabled
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.name}-${local.suffix}" })
  )

  lifecycle {
    ignore_changes = [
      read_capacity,
      write_capacity,
    ]
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }
}

