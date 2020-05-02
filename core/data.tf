data "aws_caller_identity" "current" {}

locals {
  aws_account_id  = data.aws_caller_identity.current.account_id
  api_domain      = "api.trackncovph.jclarino.com"
  graph_domain    = "graph.trackncovph.jclarino.com"
  appsync_origin  = replace(replace(aws_appsync_graphql_api.covidtracker.uris.GRAPHQL, "https://", ""), "/graphql", "")
  appsync_api_key = aws_appsync_api_key.covidtracker_key.key
}