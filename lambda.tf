##################################################
#
# Add Lambda function
# Triggered by object create on file_intake_bucket
# Calls Glue job
#
##################################################

# Create IAM policy document
data "aws_iam_policy_document" "lambda_policy_document" {
  # Access to trigger Glue jobs
  statement {
    actions   = ["glue:StartJobRun"]
    resources = ["*"]
    effect    = "Allow"
  }
  # Access to create and write logs
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
    effect    = "Allow"
  }
  # Full permission to s3
  statement {
    actions   = ["s3:*"]
    resources = ["*"]
    effect    = "Allow"
  }
}

# Create assume role policy document for lambda assuming roles
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Create IAM policy using above document
resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda-policy"
  policy = data.aws_iam_policy_document.lambda_policy_document.json
}

# Create IAM role to attach the above policy to
resource "aws_iam_role" "lambda_role" {
  name               = "lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

# Attach lambda_policy to lambda_role
resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Set retry attempts to 0
resource "aws_lambda_function_event_invoke_config" "example" {
  function_name = aws_lambda_function.lambda.function_name
  maximum_retry_attempts = 0
}

# Create Lambda function
resource "aws_lambda_function" "lambda" {
  filename         = "file-intake-function.zip"
  function_name    = "file-intake-function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "file-intake-function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("file-intake-function.zip")
}

# Give permission for Lambda to look in bucket
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.file_intake_bucket.arn
}

# Create s3 bucket notification for lambda trigger
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.file_intake_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "tenant1/"
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
