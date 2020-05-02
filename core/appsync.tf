data "local_file" "covidtracker_schema" {
  filename = "${path.module}/graphql/covidtracker.schema.graphql"
}

resource "aws_appsync_graphql_api" "covidtracker" {
  authentication_type = "API_KEY"
  name                = "covidtracker-graphql"
  schema              = data.local_file.covidtracker_schema.content
}

resource "aws_appsync_api_key" "covidtracker_key" {
  api_id  = aws_appsync_graphql_api.covidtracker.id
  expires = "2021-05-02T00:00:00Z"
}

##################################################
# GraphQL Lambda Data Source                     #
##################################################

resource "aws_appsync_datasource" "covidtracker_graph_lambda" {
  name             = "covidtracker_graph_datasource"
  api_id           = aws_appsync_graphql_api.covidtracker.id
  type             = "AWS_LAMBDA"
  service_role_arn = aws_iam_role.covidtracker_graph_datasource.arn

  lambda_config {
    function_arn = aws_lambda_function.graph_resolver.arn
  }
}

resource "aws_iam_role" "covidtracker_graph_datasource" {
  name = "covidtracker-graph-datasource"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "appsync.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "covidtracker_graph_datasource" {
  name   = "default"
  role   = aws_iam_role.covidtracker_graph_datasource.id
  policy = data.aws_iam_policy_document.covidtracker_graph_datasource.json
}

data "aws_iam_policy_document" "covidtracker_graph_datasource" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:*",
    ]
    resources = [
      "*"
    ]
  }
}

module "appsync_queries" {
  source      = "../modules-registry/appsync-resolver"
  api_id      = aws_appsync_graphql_api.covidtracker.id
  data_source = aws_appsync_datasource.covidtracker_graph_lambda.name
  queries = [
    "case",
    "cases",
    "accumulation",
    "statistics",
    "ageGenderDistribution",
    "region",
    "province",
    "city"
  ]
}