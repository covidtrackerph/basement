variable "data_source" {
  type        = string
  description = "Data source of the resolver"
}

variable "api_id" {
  type        = string
  description = "GraphQL Api ID"
}

variable "queries" {
  type        = list(string)
  description = "List of query names"
}