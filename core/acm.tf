locals {
  api_domain = "api.trackncovph.jclarino.com"
}

resource "aws_acm_certificate" "api_cert" {
  domain_name       = local.api_domain
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
}