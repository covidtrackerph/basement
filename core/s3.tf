
# =============================================== #
# CovidTrackerPH User interface                   #
# =============================================== #

resource "aws_s3_bucket" "covid_tracker_ui" {
  bucket = "covid-tracker-ui-${var.namespace}"
  region = "us-east-1"
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
    Name = "covid-tracker-ui-${var.namespace}"
  }
}


data "aws_iam_policy_document" "covid_tracker_ui" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.covid_tracker_ui.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.covid_tracker_ui.iam_arn]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.covid_tracker_ui.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.covid_tracker_ui.iam_arn]
    }
  }

  # Disallow non-TLS access
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["${aws_s3_bucket.covid_tracker_ui.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [false]
    }
  }
}

resource "aws_s3_bucket_policy" "static_uis" {
  bucket = aws_s3_bucket.covid_tracker_ui.id
  policy = data.aws_iam_policy_document.covid_tracker_ui.json
}