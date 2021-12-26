##################################################
#
# Add S3 bucket that contains logging
#
##################################################
resource "aws_s3_bucket" "log_bucket" {
  bucket        = "terraform-poc-logging"
  acl           = "log-delivery-write"
  force_destroy = true
}

# Make not public
resource "aws_s3_bucket_public_access_block" "log_bucket_pab" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

##################################################
#
# Add S3 bucket for terraform remote state
#
##################################################
# resource "aws_s3_bucket" "infrastructure_bucket" {
#   bucket = "terraform-poc-infrastructure"
#   acl    = "private"
#   versioning {
#     enabled = true
#   }

#   logging {
#     target_bucket = aws_s3_bucket.log_bucket.id
#     target_prefix = "terraform-poc-infrastructure/"
#   }
# }

# # Make not public
# resource "aws_s3_bucket_public_access_block" "infrastructure_bucket_pab" {
#   bucket = aws_s3_bucket.infrastructure_bucket.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

##################################################
#
# Add S3 bucket for file intake
#
##################################################
resource "aws_s3_bucket" "file_intake_bucket" {
  bucket        = "terraform-poc-file-intake"
  acl           = "private"
  force_destroy = true

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "terraform-poc-file-intake/"
  }

  versioning {
    enabled = true
  }
}

# Make not public
resource "aws_s3_bucket_public_access_block" "file_intake_bucket_pab" {
  bucket = aws_s3_bucket.file_intake_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Add folder for first tenant
resource "aws_s3_bucket_object" "file_intake_folder" {
  bucket = aws_s3_bucket.file_intake_bucket.id
  key    = "tenant1/"
}

##################################################
#
# Add S3 bucket for scripts
#
##################################################
resource "aws_s3_bucket" "scripts_bucket" {
  bucket        = "terraform-poc-scripts"
  acl           = "private"
  force_destroy = true

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "terraform-poc-scripts/"
  }

  versioning {
    enabled = true
  }
}

# Make not public
resource "aws_s3_bucket_public_access_block" "scripts_bucket_pab" {
  bucket = aws_s3_bucket.scripts_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}