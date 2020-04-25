output "tfstate_lock_ddb_table_name" {
  value = aws_dynamodb_table.tfstate.name
}

resource "aws_s3_bucket" "state-storage" {
  bucket = "covidtrackerph-${local.aws_account_id}"
  region = var.region
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = {
    Name        = "CovidTracker Terraform State Bucket"
    Environment = var.namespace
  }
}

resource "aws_s3_bucket_public_access_block" "state-storage" {
  bucket = aws_s3_bucket.state-storage.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}



resource "aws_dynamodb_table" "tfstate" {
  name           = "tfstate-lock"
  hash_key       = "LockID"
  read_capacity  = 2
  write_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "DynamoDB Terraform State Lock"
    Environment = var.namespace
  }
}
