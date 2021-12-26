resource "aws_dynamodb_table" "terraform-dynamodb-table" {
  name           = "TerraformPOC"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "EmployeeId"
  range_key      = "DepartmentId"

  attribute {
    name = "EmployeeId"
    type = "S"
  }

  attribute {
    name = "DepartmentId"
    type = "S"
  }

  global_secondary_index {
    name               = "Departments"
    hash_key           = "DepartmentId"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["UserId"]
  }
}
