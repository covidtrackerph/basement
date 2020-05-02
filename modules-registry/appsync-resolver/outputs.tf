output "arns" {
  value       = values(aws_appsync_resolver.query_resolver)[*].arn
  description = "ARN of all created resolvers"
}
