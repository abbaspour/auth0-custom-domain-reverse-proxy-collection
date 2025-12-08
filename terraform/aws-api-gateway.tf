// Copyright 2025 Auth0 Product Architecture Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// AWS API Gateway reverse proxy for Auth0 custom domain
locals {
  aws_apigw_domain = "aws-apigw.${var.tld}"
}

// --- ACM certificate for the custom domain (DNS validation via Cloudflare) ---
resource "aws_acm_certificate" "aws_apigw_cert" {
  domain_name       = local.aws_apigw_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

// Create DNS validation records in Cloudflare
resource "cloudflare_dns_record" "aws_apigw_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.aws_apigw_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.cloudflare_zone_id
  type    = each.value.type
  name    = each.value.name
  ttl     = 300
  content = each.value.record
}

resource "aws_acm_certificate_validation" "aws_apigw_cert_validation" {
  certificate_arn         = aws_acm_certificate.aws_apigw_cert.arn
  validation_record_fqdns = [for r in cloudflare_dns_record.aws_apigw_cert_validation : r.name]
}

// --- API Gateway HTTP API (v2) ---
resource "aws_apigatewayv2_api" "auth0_proxy" {
  name          = "auth0-custom-domain-proxy"
  protocol_type = "HTTP"
}

// Integration to Auth0 tenant (HTTP proxy)
resource "aws_apigatewayv2_integration" "auth0_upstream" {
  api_id               = aws_apigatewayv2_api.auth0_proxy.id
  integration_type     = "HTTP_PROXY"
  integration_method   = "ANY"
  integration_uri      = "https://${auth0_custom_domain_verification.aws_apigw_verification.origin_domain_name}/{proxy}"
  timeout_milliseconds = 29000

  request_parameters = {
    "append:header.cname-api-key" = auth0_custom_domain_verification.aws_apigw_verification.cname_api_key
  }
}

// ANY /{proxy+} route to upstream
resource "aws_apigatewayv2_route" "proxy_route" {
  api_id    = aws_apigatewayv2_api.auth0_proxy.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.auth0_upstream.id}"
}

// Default stage with auto-deploy
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.auth0_proxy.id
  name        = "$default"
  auto_deploy = true
}

// Custom domain for API Gateway
resource "aws_apigatewayv2_domain_name" "custom" {
  depends_on = [aws_acm_certificate_validation.aws_apigw_cert_validation]

  domain_name = local.aws_apigw_domain

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.aws_apigw_cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

// Map custom domain to the default stage
resource "aws_apigatewayv2_api_mapping" "root" {
  api_id      = aws_apigatewayv2_api.auth0_proxy.id
  domain_name = aws_apigatewayv2_domain_name.custom.domain_name
  stage       = aws_apigatewayv2_stage.default.name
}

// DNS: point the custom hostname to the API Gateway regional domain
resource "cloudflare_dns_record" "aws_apigw_cname" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = local.aws_apigw_domain
  ttl     = 300
  proxied = false
  content = aws_apigatewayv2_domain_name.custom.domain_name_configuration[0].target_domain_name
}

// --- Auth0: register and verify the custom domain ---
resource "auth0_custom_domain" "aws_apigw" {
  domain                  = local.aws_apigw_domain
  type                    = "self_managed_certs"
  custom_client_ip_header = "x-forwarded-for"
  domain_metadata = {
    server = "aws-apigw"
  }
}

resource "cloudflare_dns_record" "aws_apigw_verification_record" {
  zone_id = var.cloudflare_zone_id
  type    = upper(auth0_custom_domain.aws_apigw.verification[0].methods[0].name)
  name    = auth0_custom_domain.aws_apigw.verification[0].methods[0].domain
  ttl     = 300
  content = "\"${auth0_custom_domain.aws_apigw.verification[0].methods[0].record}\""
}

resource "auth0_custom_domain_verification" "aws_apigw_verification" {
  depends_on       = [cloudflare_dns_record.aws_apigw_verification_record]
  custom_domain_id = auth0_custom_domain.aws_apigw.id
  timeouts { create = "15m" }
}

output "aws_apigw_custom_domain" {
  value = local.aws_apigw_domain
}

output "aws_apigw_invoke_url" {
  value = aws_apigatewayv2_api.auth0_proxy.api_endpoint
}
