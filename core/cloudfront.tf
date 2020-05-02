resource "random_string" "origin_id" {
  length           = 12
  special          = true
  override_special = "$#"
}

locals {
  appsync_origin_id = "${random_string.origin_id.result}-${local.appsync_origin}"
}

resource "aws_cloudfront_distribution" "appsync_distribution" {

  enabled         = true
  is_ipv6_enabled = true
  comment         = "Managed by Terraform"

#   aliases = [
#     local.graph_domain
#   ]

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
    cloudfront_default_certificate = true
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
