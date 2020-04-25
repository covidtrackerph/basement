# locals {
#     s3_origin_id = "covidtracker-origin"
# }




# resource "aws_s3_bucket" "covidtracker_ui" {
#   bucket = "covidtracker_ui"
#   acl    = "public-read"

#   cors_rule {
#     allowed_headers = ["*"]
#     allowed_methods = ["PUT", "POST"]
#     allowed_origins = ["*"]
#     expose_headers  = ["ETag"]
#     max_age_seconds = 3000
#   }

#   policy = data.aws_iam_policy_document.covidtracker_ui_policy.json
# }

# data "aws_iam_policy_document" "covidtracker_ui_policy" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "secretsmanager:*",
#     ]
#     resources = [
#       "*"
#     ]
#   }
# }

# resource "aws_cloudfront_distribution" "covidtracker_distribution" {
#     origin {
#         domain_name = aws_s3_bucket.covidtracker_ui.website_endpoint
#         origin_id = local.s3_origin_id

#         custom_origin_config {
#             http_port = 80
#             https_port = 443
#             origin_protocol_policy = "https-only"
#             origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
#         }
#     }

#     default_root_object = "index.html"
#     enabled = true

#     custom_error_response {
#         error_caching_min_ttl = 3000
#         error_code = 404
#         response_code = 200
#         response_page_path = "/index.html"
#     }
# }
