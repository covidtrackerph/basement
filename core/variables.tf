variable "covid_rds_password" {
  type = string
  description = "Password for Covid RDS"
}

variable "region" {
    type = string
    description = "AWS Region"
    default = "ap-southeast-1"
}

variable "namespace" {
    type = string
    description = "Project namespace"
    default = "prod"
}