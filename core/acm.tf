resource "aws_acm_certificate" "api_cert" {
  domain_name       = aws_api_gateway_domain_name.covid_tracker_api_domain_name.domain_name
  validation_method = "DNS"

  tags = {
    Environment = var.namespace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "api_cert" {
  certificate_arn = aws_acm_certificate.api_cert.arn
  timeouts {
    create = "2h"
  }
}