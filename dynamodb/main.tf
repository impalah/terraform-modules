################################################################################
# Dynamodb table
################################################################################

resource "aws_dynamodb_table" "table" {

  dynamic "attribute" {
    for_each = var.table_attributes
    content {
      name = attribute.value["name"]
      type = attribute.value["type"]
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      write_capacity  = global_secondary_index.value.write_capacity
      read_capacity   = global_secondary_index.value.read_capacity
      projection_type = global_secondary_index.value.projection_type
    }
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  name     = var.table_name
  hash_key = var.hash_key
  billing_mode                = var.billing_mode
  deletion_protection_enabled = var.deletion_protection_enabled
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  stream_enabled = var.stream_enabled
  table_class    = var.table_class
}