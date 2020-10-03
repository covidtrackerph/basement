##################################################
# Shared                                #
##################################################

data "aws_iam_policy" "lambda_basic_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


##################################################
# Graph Lambda                                   #
##################################################

data "archive_file" "graph" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/graph-node/build/"
  output_path = "${path.module}/lambda_functions/graph-node/function.zip"
}

resource "aws_lambda_function" "graph" {
  filename         = data.archive_file.graph.output_path
  source_code_hash = filebase64sha256(data.archive_file.graph.output_path)
  function_name    = "graph"
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  timeout          = 30
  publish          = false
  memory_size      = 256
  role             = aws_iam_role.graph.arn
  environment {
    variables = {
      COVIDTRACKER_DB_CONNECTION_SECRET_ID = "covidrds",
      environment                          = "Production"
    }
  }
}

resource "aws_lambda_permission" "graph" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.graph.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_iam_role" "graph" {
  name               = "graph"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "apigateway.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "graph" {
  name   = "default"
  role   = aws_iam_role.graph.id
  policy = data.aws_iam_policy_document.graph.json
}

data "aws_iam_policy_document" "graph" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:*",
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "graph_logging" {
  role       = aws_iam_role.graph.name
  policy_arn = data.aws_iam_policy.lambda_basic_execution.arn
}

resource "aws_cloudwatch_log_group" "graph" {
  name              = "/aws/lambda/graph-${var.namespace}"
  retention_in_days = 14
}

##################################################
# Case Collection Lambda                         #
##################################################

data "archive_file" "case_collection" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/case-collection/build/"
  output_path = "${path.module}/lambda_functions/case-collection/function.zip"
}

resource "aws_lambda_function" "case_collection" {
  filename         = data.archive_file.case_collection.output_path
  source_code_hash = filebase64sha256(data.archive_file.case_collection.output_path)
  function_name    = "case-collection"
  handler          = "CaseCollection::CaseCollection.LambdaEntry::RunAsync"
  runtime          = "dotnetcore3.1"
  timeout          = 900
  publish          = false
  memory_size      = 256
  role             = aws_iam_role.case_collection.arn
  environment {
    variables = {
      DRIVE_CONFIG_SECRET_ID               = "googleaccesskey",
      COVIDTRACKER_DB_CONNECTION_SECRET_ID = "covidrds",
      environment                          = "Production"
    }
  }
}

resource "aws_lambda_permission" "case_collection_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.case_collection.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "case_collection_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.case_collection.function_name
  principal     = "events.amazonaws.com"
}

resource "aws_iam_role" "case_collection" {
  name               = "case-collection"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "apigateway.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "case_collection" {
  name   = "default"
  role   = aws_iam_role.case_collection.id
  policy = data.aws_iam_policy_document.case_collection.json
}

data "aws_iam_policy_document" "case_collection" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:*",
    ]
    resources = [
      "*"
    ]
  }
}


resource "aws_iam_role_policy_attachment" "case_collection_logging" {
  role       = aws_iam_role.case_collection.name
  policy_arn = data.aws_iam_policy.lambda_basic_execution.arn
}

resource "aws_cloudwatch_log_group" "case_collection" {
  name              = "/aws/lambda/case_collection-${var.namespace}"
  retention_in_days = 14
}

##################################################
# Google Verification                            #
##################################################

data "archive_file" "google_verification" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/google-verification/build/"
  output_path = "${path.module}/lambda_functions/google-verification/function.zip"
}

resource "aws_lambda_function" "google_verification" {
  filename         = data.archive_file.google_verification.output_path
  source_code_hash = filebase64sha256(data.archive_file.google_verification.output_path)
  function_name    = "google-verification"
  handler          = "index.handler"
  runtime          = "nodejs10.x"
  timeout          = 15
  publish          = false
  memory_size      = 128
  role             = aws_iam_role.google_verification.arn
}

resource "aws_lambda_permission" "google_verification_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.google_verification.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_iam_role" "google_verification" {
  name               = "google-verification"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "apigateway.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}


##################################################
# GraphQL Resolver Lambda                        #
##################################################

data "archive_file" "graph_resolver" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/graph-resolver/build/"
  output_path = "${path.module}/lambda_functions/graph-resolver/function.zip"
}

resource "aws_lambda_function" "graph_resolver" {
  filename         = data.archive_file.graph_resolver.output_path
  source_code_hash = filebase64sha256(data.archive_file.graph_resolver.output_path)
  function_name    = "graph-resolver"
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  timeout          = 30
  publish          = false
  memory_size      = 256
  role             = aws_iam_role.graph_resolver.arn
  environment {
    variables = {
      COVIDTRACKER_DB_CONNECTION_SECRET_ID = "covidrds",
      environment                          = "Production"
    }
  }
}

resource "aws_lambda_permission" "graph_resolver" {
  statement_id  = "AllowExecutionFromAppSync"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.graph_resolver.function_name
  principal     = "appsync.amazonaws.com"
}

resource "aws_iam_role" "graph_resolver" {
  name               = "graph-resolver"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "appsync.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "graph_resolver" {
  name   = "default"
  role   = aws_iam_role.graph_resolver.id
  policy = data.aws_iam_policy_document.graph_resolver.json
}

data "aws_iam_policy_document" "graph_resolver" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:*",
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "graph_resolver_logging" {
  role       = aws_iam_role.graph_resolver.name
  policy_arn = data.aws_iam_policy.lambda_basic_execution.arn
}

resource "aws_cloudwatch_log_group" "graph_resolver" {
  name              = "/aws/lambda/graph-resolver-${var.namespace}"
  retention_in_days = 14
}

##################################################
# Static path rewrite for serving UI             #
##################################################

data "archive_file" "static_ui_path_rewrite_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/ui-path-rewrite/build/"
  output_path = "${path.module}/lambda_functions/ui-path-rewrite/function.zip"
}

resource "aws_lambda_function" "static_ui_path_rewrite" {
  provider         = aws.us_east_1
  filename         = data.archive_file.static_ui_path_rewrite_lambda.output_path
  source_code_hash = filebase64sha256(data.archive_file.static_ui_path_rewrite_lambda.output_path)
  function_name    = "static-ui-path-rewrite-${var.namespace}"
  handler          = "index.handler"
  role             = aws_iam_role.static_ui_path_rewrite_lambda.arn
  runtime          = "nodejs12.x"
  memory_size      = "128"
  timeout          = 5
  publish          = true
}

resource "aws_iam_role" "static_ui_path_rewrite_lambda" {
  name = "static-ui-path-rewrite-lambda"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "static_ui_path_rewrite_lambda_logging" {
  role       = aws_iam_role.static_ui_path_rewrite_lambda.name
  policy_arn = data.aws_iam_policy.lambda_basic_execution.arn
}


####################################################
# Guest token insertion to cloudfront distribution #
####################################################

data "archive_file" "guest_token_inserter" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/ui-guest-token/build/"
  output_path = "${path.module}/lambda_functions/ui-guest-token/function.zip"
}

resource "aws_lambda_function" "guest_token_inserter" {
  provider         = aws.us_east_1
  filename         = data.archive_file.guest_token_inserter.output_path
  source_code_hash = filebase64sha256(data.archive_file.guest_token_inserter.output_path)
  function_name    = "guest-token-inserter-${var.namespace}"
  handler          = "index.handler"
  role             = aws_iam_role.guest_token_inserter.arn
  runtime          = "nodejs12.x"
  memory_size      = "128"
  timeout          = 5
  publish          = true
}

resource "aws_iam_role" "guest_token_inserter" {
  name = "guest-token-inserter-lambda"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "guest_token_inserter_logging" {
  role       = aws_iam_role.guest_token_inserter.name
  policy_arn = data.aws_iam_policy.lambda_basic_execution.arn
}