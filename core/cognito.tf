# =============================================== #
# COVID TrackerPH Main User Pool                  #
# =============================================== #

# Using default domain
resource "aws_cognito_user_pool_domain" "covid_tracker" {
  domain       = "hermes-project"
  user_pool_id = aws_cognito_user_pool.covid_tracker_user_pool.id
}


resource "aws_cognito_user_pool" "covid_tracker_user_pool" {
  name = "covid-tracker-user-pool-${var.namespace}"

  # Allow user self registration
  admin_create_user_config {
    allow_admin_create_user_only = "false"
  }

  # Use email as username
  alias_attributes = [
    "email",
    "phone_number",
    "preferred_username"
  ]

  username_configuration {
    case_sensitive = false
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 365
  }

  # Set to cognito default for now
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # MFA Settings
  mfa_configuration = "OFF"

  sms_configuration {
    external_id    = local.sms_config_external_id
    sns_caller_arn = aws_iam_role.sms_role.arn
  }

  software_token_mfa_configuration {
    enabled = false
  }

  device_configuration {
    # Device is only remembered on user prompt.
    device_only_remembered_on_user_prompt = "true"
  }

  # Account confirmation 
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "United in Research Email Verification"
    email_message        = "Your verification code is: {####}"
    sms_message          = "Your CovidTrackerPH verification code is: {####}"
  }

  # Enables advanced security features for AWS Cognito
  # Enabling adds a additional cost of $0.050 per MAU (monthly active user)
  # OFF / AUDIT / ENFORCED
  user_pool_add_ons {
    advanced_security_mode = "OFF"
  }


  # Attributes
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = "false"
    mutable                  = "true"
    name                     = "email"
    required                 = "true"

    string_attribute_constraints {
      min_length = 0
      max_length = 256
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = "false"
    mutable                  = "true"
    name                     = "phone_number"
    required                 = "true"

    string_attribute_constraints {
      min_length = 0
      max_length = 128
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = "false"
    mutable                  = "true"
    name                     = "given_name"
    required                 = "true"

    string_attribute_constraints {
      min_length = 1
      max_length = 128
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = "false"
    mutable                  = "true"
    name                     = "family_name"
    required                 = "true"

    string_attribute_constraints {
      min_length = 1
      max_length = 128
    }
  }

  lifecycle {
    # See note above regarding custom attributes
    ignore_changes = [
      schema
    ]
  }
}

resource "aws_cognito_user_pool_client" "covid_tracker" {
  name            = "covid-tracker-client-${var.namespace}"
  user_pool_id    = aws_cognito_user_pool.covid_tracker_user_pool.id
  generate_secret = "false"
  callback_urls   = var.covid_tracker_ui_callback_urls
  logout_urls     = var.covid_tracker_ui_logout_urls
  # The scope aws.cognito.signin.user.admin allows the user to update their user attributes
  allowed_oauth_scopes                 = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
  allowed_oauth_flows                  = ["code", "implicit"]
  supported_identity_providers         = ["COGNITO"]
  refresh_token_validity               = "30"
  allowed_oauth_flows_user_pool_client = "true"
  explicit_auth_flows                  = ["USER_PASSWORD_AUTH", "ADMIN_NO_SRP_AUTH"]

  # Attaches these claims to the ID Token
  read_attributes = [
    "address",
    "email",
    "email_verified",
    "phone_number",
    "phone_number_verified",
    "birthdate",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo"
  ]
}

resource "aws_cognito_user_pool_client" "user_management" {
  name            = "user-management-client-${var.namespace}"
  user_pool_id    = aws_cognito_user_pool.covid_tracker_user_pool.id
  generate_secret = "false"
  callback_urls   = var.user_management_callback_urls
  logout_urls     = var.user_management_logout_urls
  # The scope aws.cognito.signin.user.admin allows the user to update their user attributes
  allowed_oauth_scopes                 = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
  allowed_oauth_flows                  = ["code", "implicit"]
  supported_identity_providers         = ["COGNITO"]
  refresh_token_validity               = "30"
  allowed_oauth_flows_user_pool_client = "true"
  explicit_auth_flows                  = ["USER_PASSWORD_AUTH", "ADMIN_NO_SRP_AUTH"]

  write_attributes = [
    "address",
    "email",
    "phone_number",
    "birthdate",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "picture",
    "preferred_username",
    "profile",
    "website",
    "zoneinfo"
  ]

  # Attaches these claims to the ID Token
  read_attributes = [
    "address",
    "email",
    "email_verified",
    "phone_number",
    "phone_number_verified",
    "birthdate",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo"
  ]
}

# =============================================== #
# COVID TrackerPH Main Identity Pool              #
# =============================================== #


resource "aws_cognito_identity_pool" "covid_tracker" {
  identity_pool_name               = "covid_tracker_identity_pool_${var.namespace}"
  allow_unauthenticated_identities = true

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.covid_tracker.id
    provider_name           = aws_cognito_user_pool.covid_tracker_user_pool.endpoint
    server_side_token_check = false
  }
}
