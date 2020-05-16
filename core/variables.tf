variable "region" {
  type        = string
  description = "AWS Region"
  default     = "ap-southeast-1"
}

variable "namespace" {
  type        = string
  description = "Project namespace"
  default     = "prod"
}

variable "global_tags" { }

variable "user_management_callback_urls" {
  type        = list(string)
  description = "Callbacks for user management UI"
}

variable "user_management_logout_urls" {
  type        = list(string)
  description = "Logout callbacks for user management UI"
}


variable "covid_tracker_ui_callback_urls" {
  type        = list(string)
  description = "Callbacks for covid tracker UI"
}

variable "covid_tracker_ui_logout_urls" {
  type        = list(string)
  description = "Logout callbacks for covid tracker UI"
}
