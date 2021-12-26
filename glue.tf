##################################################
#
# Create Glue script
#
##################################################

# Create IAM policy document
data "aws_iam_policy_document" "glue_policy_document" {
  # Access to read/write to DynamoDb
  statement {
    actions   = ["dynamodb:PutItem"]
    resources = ["arn:aws:dynamodb:us-east-1:735749617122:table/TerraformPOC"]
    effect    = "Allow"
  }
  # Access to read the python script from s3
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::terraform-poc-scripts/glue/file-intake/file-intake-job.py"]
    effect    = "Allow"
  }
  # Access to create and write logs
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:/aws-glue/*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
    effect    = "Allow"
  }
}

# Create assume role policy document for glue assuming roles
data "aws_iam_policy_document" "glue_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

# Create IAM policy using above document
resource "aws_iam_policy" "glue_policy" {
  name   = "glue-policy"
  policy = data.aws_iam_policy_document.glue_policy_document.json
}

# Create IAM role to attach the above policy to
resource "aws_iam_role" "glue_role" {
  name               = "glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role_policy.json
}

# Attach glue_policy to glue_role
resource "aws_iam_role_policy_attachment" "glue_role_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}

# Create cloudwatch log group for Glue logs
resource "aws_cloudwatch_log_group" "glue_logs" {
  name              = "glue-logs"
  retention_in_days = 14
}

# Create Glue job
resource "aws_glue_job" "glue_job" {
  name     = "file-intake-job"
  role_arn = aws_iam_role.glue_role.arn

  command {
    script_location = "s3://${aws_s3_bucket.scripts_bucket.bucket}/glue/file-intake/file-intake-job.py"
    python_version  = "3"
  }

  glue_version      = "2.0"
  worker_type       = "G.2X"
  number_of_workers = "20"
}

# Add file for Glue script
resource "aws_s3_bucket_object" "scripts" {
  bucket = aws_s3_bucket.scripts_bucket.id
  key    = "glue/file-intake/file-intake-job.py"
  source = "file-intake-job.py"
  etag   = filemd5("file-intake-job.py")
}
