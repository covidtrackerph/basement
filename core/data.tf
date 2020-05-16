data "aws_caller_identity" "current" {}

locals {
  aws_account_id              = data.aws_caller_identity.current.account_id
  api_domain                  = "api.trackncovph.jclarino.com"
  graph_domain                = "graph.trackncovph.jclarino.com"
  covid_tracker_ui_domain     = "trackncovph.jclarino.com"
  covid_tracker_ui_domain_alt = "covidtracker.ph"
  appsync_origin              = replace(replace(aws_appsync_graphql_api.covidtracker.uris.GRAPHQL, "https://", ""), "/graphql", "")
  appsync_api_key             = aws_appsync_api_key.covidtracker_key.key
  sms_config_external_id      = "covid_tracker_sns${var.region}_${var.namespace}"
}



