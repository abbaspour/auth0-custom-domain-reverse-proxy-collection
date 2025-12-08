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

// AWS CloudFront reverse proxy for Auth0 custom domain
locals {
  aws_cf_domain = "aws-cf.${var.tld}"
}

// --- ACM certificate for CloudFront custom domain (must be in us-east-1) ---
resource "aws_acm_certificate" "aws_cf_cert" {
  provider          = aws.us_east_1
  domain_name       = local.aws_cf_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

// Create DNS validation records in Cloudflare for the ACM cert
resource "cloudflare_dns_record" "aws_cf_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.aws_cf_cert.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "aws_cf_cert_validation" {
  provider                 = aws.us_east_1
  certificate_arn         = aws_acm_certificate.aws_cf_cert.arn
  validation_record_fqdns = [for r in cloudflare_dns_record.aws_cf_cert_validation : r.name]
}

// --- Auth0: register and verify the custom domain ---
resource "auth0_custom_domain" "aws_cf" {
  domain                  = local.aws_cf_domain
  type                    = "self_managed_certs"
  custom_client_ip_header = "x-forwarded-for"
  domain_metadata = {
    server = "aws-cloudfront"
  }
}

// DNS record for Auth0 verification
resource "cloudflare_dns_record" "aws_cf_verification_record" {
  zone_id = var.cloudflare_zone_id
  type    = upper(auth0_custom_domain.aws_cf.verification[0].methods[0].name)
  name    = auth0_custom_domain.aws_cf.verification[0].methods[0].domain
  ttl     = 300
  content = "\"${auth0_custom_domain.aws_cf.verification[0].methods[0].record}\""
}

resource "auth0_custom_domain_verification" "aws_cf_verification" {
  depends_on       = [cloudflare_dns_record.aws_cf_verification_record]
  custom_domain_id = auth0_custom_domain.aws_cf.id
  timeouts { create = "15m" }
}

// --- CloudFront distribution acting as reverse proxy ---

// Managed policies for no-cache and all viewer headers
data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host" {
  // Do not forward Host header so origin receives its own hostname as Host
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_distribution" "auth0_proxy" {
  depends_on = [aws_acm_certificate_validation.aws_cf_cert_validation]

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  aliases             = [local.aws_cf_domain]
  wait_for_deployment = false

  origin {
    domain_name = auth0_custom_domain_verification.aws_cf_verification.origin_domain_name
    origin_id   = "auth0-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_keepalive_timeout = 60
      origin_protocol_policy = "https-only"
      origin_read_timeout    = 60
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    // Pass required header for Auth0 custom domain
    custom_header {
      name  = "cname-api-key"
      value = auth0_custom_domain_verification.aws_cf_verification.cname_api_key
    }
  }

  default_cache_behavior {
    target_origin_id       = "auth0-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"
    ]
    cached_methods = ["GET", "HEAD", "OPTIONS"]

    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.aws_cf_cert.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}

// DNS: point the custom hostname to the CloudFront distribution
resource "cloudflare_dns_record" "aws_cf_cname" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = local.aws_cf_domain
  ttl     = 300
  proxied = false
  content = aws_cloudfront_distribution.auth0_proxy.domain_name
}

output "aws_cf_custom_domain" {
  value = local.aws_cf_domain
}

output "aws_cf_distribution_domain" {
  value = aws_cloudfront_distribution.auth0_proxy.domain_name
}
