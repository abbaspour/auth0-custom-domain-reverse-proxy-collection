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

locals {
  caddy_domain = "caddy.${var.tld}"
}

// -- caddy --
resource "cloudflare_dns_record" "caddy" {
  zone_id = var.cloudflare_zone_id
  type = "CNAME"
  name = local.caddy_domain
  ttl     = 300
  content = "lab.${var.tld}"
}

resource "auth0_custom_domain" "caddy" {
  domain = local.caddy_domain
  type   = "self_managed_certs"
}

resource "cloudflare_dns_record" "caddy_verification_record" {
  zone_id = var.cloudflare_zone_id
  type = upper(auth0_custom_domain.caddy.verification[0].methods[0].name)
  name = auth0_custom_domain.caddy.verification[0].methods[0].domain
  ttl     = 300
  content = "\"${auth0_custom_domain.caddy.verification[0].methods[0].record}\""
}

resource "auth0_custom_domain_verification" "caddy_verification" {
  depends_on = [cloudflare_dns_record.caddy_verification_record]
  custom_domain_id = auth0_custom_domain.caddy.id
  timeouts { create = "15m" }
}

resource "local_file" "caddy-dot_env" {
  filename = "${path.module}/../caddy/.env"
  file_permission = "600"
  content  = <<-EOT
CNAME_API_KEY=${auth0_custom_domain_verification.caddy_verification.cname_api_key}
AUTH0_EDGE_LOCATION=${auth0_custom_domain_verification.caddy_verification.origin_domain_name}
DOMAIN_NAME=${local.caddy_domain}
EOT
}

// -- tls --
resource "acme_registration" "caddy_reg" {
  account_key_pem = tls_private_key.account_private_key.private_key_pem
  email_address   = "admin@${local.caddy_domain}"
}

resource "acme_certificate" "caddy_certificate" {
  account_key_pem           = acme_registration.caddy_reg.account_key_pem
  common_name               = local.caddy_domain
  subject_alternative_names = [local.caddy_domain]

  dns_challenge {
    provider = "cloudflare"
    config = {
      CF_API_EMAIL = var.cloudflare_email
      CF_API_KEY = var.cloudflare_api_key
      CF_ZONE_API_KEY = var.cloudflare_zone_id
    }
  }

  min_days_remaining = 30
}


resource "local_file" "caddy_private_key" {
  content = acme_certificate.caddy_certificate.private_key_pem
  filename = "${path.cwd}/../caddy/privkey.pem"
  file_permission = "600"
}

resource "local_file" "caddy_fullchain" {
  content  = "${acme_certificate.caddy_certificate.certificate_pem}${acme_certificate.caddy_certificate.issuer_pem}"
  filename = "${path.cwd}/../caddy/fullchain.pem"
  file_permission = "600"
}
