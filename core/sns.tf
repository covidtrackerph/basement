
resource "aws_iam_role" "sms_role" {
  name = "SMS-${var.namespace}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "cognito-idp.amazonaws.com"
            },
            "Action": "sts:AssumeRole",
            "Condition": {"StringEquals": {"sts:ExternalId": "${local.sms_config_external_id}"}}
        }
    ]
}
EOF

  tags = merge(var.global_tags, {
    Name = "SMS-${var.namespace}"
  })
}

resource "aws_iam_role_policy" "sms_role_policy" {
  name = "SMS-Policy-${var.namespace}"
  role = aws_iam_role.sms_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sns:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

# SNS SMS prefrences
resource "aws_sns_sms_preferences" "mobile_users" {
  default_sms_type = "Transactional"
}