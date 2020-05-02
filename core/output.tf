# output "aws_account_id" {
#   value = local.aws_account_id
# }

# output "aws_caller_arn" {
#   value = data.aws_caller_identity.current.arn
# }

# output "aws_caller_user" {
#   value = data.aws_caller_identity.current.user_id
# }

# output "covid_rds_username" {
#   value = aws_db_instance.covid_rds.username
# }

# output "covid_rds_password" {
#   value = aws_db_instance.covid_rds.password
# }

# output "covid_rds_port" {
#   value = aws_db_instance.covid_rds.port
# }

# output "covid_rds_endpoint" {
#   value = aws_db_instance.covid_rds.endpoint
# }

# output "api_url" {
#   value = aws_api_gateway_deployment.covid_tracker.invoke_url
# }

# output "domain_validation" {
#   value       = aws_acm_certificate.api_cert.domain_validation_options
#   description = "Certificate domain name validation options"
# }

# output "api_key" {
#   value       = aws_appsync_api_key.covidtracker_key
#   description = "AppSync API Key"
# }

# output "graph_domain_validation" {
#   value       = aws_acm_certificate.graph_cert.domain_validation_options
#   description = "GraphQL Certificate domain name validation options"
# }