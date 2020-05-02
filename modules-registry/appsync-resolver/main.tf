resource "aws_appsync_resolver" "query_resolver" {
  for_each    = toset(var.queries)
  api_id      = var.api_id
  field       = each.value
  type        = "Query"
  data_source = var.data_source

  request_template = <<EOF
{
    "version": "2017-02-28",
    "operation": "Invoke",
    "payload": {
        "field": "${each.value}",
        "args": $utils.toJson($context.arguments)
    }
}
EOF

  response_template = "$utils.toJson($context.result)"
}
