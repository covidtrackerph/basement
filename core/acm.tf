resource "aws_acm_certificate" "api_cert" {
  domain_name       = local.api_domain
  validation_method = "DNS"

  tags = {
    Name        = "API Endpoint Covid Tracker"
    Environment = var.namespace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "api_cert" {
  certificate_arn = aws_acm_certificate.api_cert.arn
}

resource "aws_acm_certificate" "graph_cert" {
  domain_name       = local.graph_domain
  validation_method = "DNS"

  tags = {
    Name        = "Graph endpoint covidtracker"
    Environment = var.namespace
  }

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_acm_certificate_validation" "graph_api_cert" {
#   certificate_arn = aws_acm_certificate.api_cert.arn
# }