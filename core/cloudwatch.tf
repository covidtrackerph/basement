resource "aws_cloudwatch_event_rule" "covid_drop_collection" {
  name                = "covid-data-drop-collection-${var.namespace}"
  description         = "Managed by Terraform. Collects data from Google Drive between 6pm - 10pm"
  schedule_expression = "cron(0 0/3 * 1/1 * ? *)"
  # "cron(0 18-22 * * ? *)"
}

resource "aws_cloudwatch_event_target" "covid_collection_target" {
  arn       = aws_lambda_function.case_collection.arn
  rule      = aws_cloudwatch_event_rule.covid_drop_collection
  target_id = "covid-data-collection"
  input     = "{\"test\":\"collect\"}"
}