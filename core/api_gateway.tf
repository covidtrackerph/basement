resource "aws_api_gateway_rest_api" "covid_tracker" {
  name        = "covid-tracker-${var.namespace}"
  description = "Covid Tracker API Gateway for ${var.namespace}"

  endpoint_configuration {
    types = ["EDGE"]
  }

  tags = {
    Name        = "covid-tracker-${var.namespace}"
    Environment = var.namespace
  }
}

resource "aws_api_gateway_deployment" "covid_tracker" {
  rest_api_id = aws_api_gateway_rest_api.covid_tracker.id

  # Force deployments during changes to this file. Refer https://github.com/terraform-providers/terraform-provider-aws/issues/162
  variables = {
    trigger = md5(file("${path.module}/api_gateway.tf"))
  }

  # Depends on all gateway configs
  depends_on = [
    aws_api_gateway_resource.case,
    aws_api_gateway_resource.case_collection,
    aws_api_gateway_method.case_collection,
    aws_api_gateway_integration.case_collection,
    aws_api_gateway_resource.google_verification,
    aws_api_gateway_method.google_verification,
    aws_api_gateway_integration.google_verification,
    aws_api_gateway_resource.graph,
    aws_api_gateway_method.graphql,
    aws_api_gateway_integration.graph
  ]

  lifecycle {
    create_before_destroy = true
  }

  stage_name = "prod"
}



##################################################
# Graph Lambda                         #
##################################################

resource "aws_api_gateway_resource" "graph" {
  rest_api_id = aws_api_gateway_rest_api.covid_tracker.id
  parent_id   = aws_api_gateway_rest_api.covid_tracker.root_resource_id
  path_part   = "graph"
}

resource "aws_api_gateway_method" "graphql" {
  rest_api_id   = aws_api_gateway_rest_api.covid_tracker.id
  resource_id   = aws_api_gateway_resource.graph.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "graph" {
  rest_api_id             = aws_api_gateway_rest_api.covid_tracker.id
  resource_id             = aws_api_gateway_resource.graph.id
  http_method             = aws_api_gateway_method.graphql.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.graph.invoke_arn
}


##################################################
# Case Collection Lambda                         #
##################################################

resource "aws_api_gateway_resource" "case" {
  rest_api_id = aws_api_gateway_rest_api.covid_tracker.id
  parent_id   = aws_api_gateway_rest_api.covid_tracker.root_resource_id
  path_part   = "case"
}

resource "aws_api_gateway_resource" "case_collection" {
  rest_api_id = aws_api_gateway_rest_api.covid_tracker.id
  parent_id   = aws_api_gateway_resource.case.id
  path_part   = "collect"
}

resource "aws_api_gateway_method" "case_collection" {
  rest_api_id   = aws_api_gateway_rest_api.covid_tracker.id
  resource_id   = aws_api_gateway_resource.case_collection.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "case_collection" {
  rest_api_id             = aws_api_gateway_rest_api.covid_tracker.id
  resource_id             = aws_api_gateway_resource.case_collection.id
  http_method             = aws_api_gateway_method.case_collection.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.case_collection.invoke_arn
}

##################################################
# Google Verification                            #
##################################################

resource "aws_api_gateway_resource" "google_verification" {
  rest_api_id = aws_api_gateway_rest_api.covid_tracker.id
  parent_id   = aws_api_gateway_rest_api.covid_tracker.root_resource_id
  path_part   = "google369e26c214f0b8a9.html"
}

resource "aws_api_gateway_method" "google_verification" {
  rest_api_id   = aws_api_gateway_rest_api.covid_tracker.id
  resource_id   = aws_api_gateway_resource.google_verification.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "google_verification" {
  rest_api_id             = aws_api_gateway_rest_api.covid_tracker.id
  resource_id             = aws_api_gateway_resource.google_verification.id
  http_method             = aws_api_gateway_method.google_verification.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.google_verification.invoke_arn
}
