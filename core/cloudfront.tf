resource "random_string" "origin_id" {
  length           = 12
  special          = true
  override_special = "$#"
}

locals {
  appsync_origin_id = "${random_string.origin_id.result}-${local.appsync_origin}"
}

# =============================================== #
# Appsync Distribution                            #
# =============================================== #

resource "aws_cloudfront_distribution" "appsync_distribution" {

  enabled         = true
  is_ipv6_enabled = true
  comment         = "Managed by Terraform"

  aliases = [
    local.graph_domain
  ]

  origin {

    origin_id   = local.appsync_origin_id
    domain_name = local.appsync_origin
    origin_path = "/graphql"

    custom_header {
      name  = "x-api-key"
      value = local.appsync_api_key
    }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2"
      ]
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.graph_cert_east_1.certificate_arn
    ssl_support_method  = "sni-only"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.appsync_origin_id
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

}

# =============================================== #
# CovidTrackerPH UI Distribution                  #
# =============================================== #
resource "aws_cloudfront_origin_access_identity" "covid_tracker_ui" {
  comment = "Origin access identity for CovidTracker UI"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    origin_id   = "S3-${aws_s3_bucket.covid_tracker_ui.bucket}"
    domain_name = aws_s3_bucket.covid_tracker_ui.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.covid_tracker_ui.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "Covid Tracker PH UI"
  http_version    = "http2"

  #   logging_config {
  #     include_cookies = false
  #     bucket          = "${aws_s3_bucket.covid_tracker_ui.bucket}.s3.amazonaws.com"
  #     prefix          = "${local.s3_path}"
  #   }

  aliases = [
    local.covid_tracker_ui_domain,
    local.covid_tracker_ui_domain_alt
  ]

  viewer_certificate {
    ssl_support_method       = "sni-only"
    acm_certificate_arn      = aws_acm_certificate_validation.covid_tracker_ui_cert.certificate_arn
    minimum_protocol_version = "TLSv1.1_2016"
  }

  # Prevent caching errors
  dynamic "custom_error_response" {
    for_each = [400, 403, 404, 500, 501, 502, 503]
    iterator = status_code

    content {
      error_code            = status_code.value
      error_caching_min_ttl = 0
    }
  }

  default_cache_behavior {
    target_origin_id       = "S3-${aws_s3_bucket.covid_tracker_ui.bucket}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["HEAD", "GET"]
    cached_methods         = ["HEAD", "GET"]
    compress               = true

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.static_ui_path_rewrite.qualified_arn
      include_body = false
    }
  }

  price_class = "PriceClass_100"
  #   web_acl_id  = aws_waf_web_acl.waf_acl.id

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "production"
  }
}
