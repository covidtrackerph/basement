##################################################
# API Gateway Certificate                        #
##################################################

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

##################################################
# AppSync  Certificate                           #
##################################################

resource "aws_acm_certificate" "graph_cert_east_1" {
  provider          = aws.us_east_1
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

resource "aws_acm_certificate_validation" "graph_cert_east_1" {
  provider        = aws.us_east_1
  certificate_arn = aws_acm_certificate.graph_cert_east_1.arn
}

##################################################
# UI certificates                                #
# * trackncovph.jclarino.com                     #
# * covidtracker.ph                              #
##################################################

resource "aws_acm_certificate" "covid_tracker_ui_cert" {
  provider    = aws.us_east_1
  domain_name = local.covid_tracker_ui_domain
  subject_alternative_names = [
    local.covid_tracker_ui_domain_alt
  ]

  validation_method = "DNS"

  tags = {
    Name        = "Alternative Domain for Covid Tracker PH UI"
    Environment = var.namespace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "covid_tracker_ui_cert" {
  provider        = aws.us_east_1
  certificate_arn = aws_acm_certificate.covid_tracker_ui_cert.arn
}