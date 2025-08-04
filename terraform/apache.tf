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
  apache_domain = "apache.${var.tld}"
}

// -- apache --
resource "cloudflare_dns_record" "apache" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = local.apache_domain
  ttl     = 300
  content = "lab.${var.tld}"
}

resource "auth0_custom_domain" "apache" {
  domain = local.apache_domain
  type   = "self_managed_certs"
}

resource "cloudflare_dns_record" "apache_verification_record" {
  zone_id = var.cloudflare_zone_id
  type    = upper(auth0_custom_domain.apache.verification[0].methods[0].name)
  name    = auth0_custom_domain.apache.verification[0].methods[0].domain
  ttl     = 300
  content = "\"${auth0_custom_domain.apache.verification[0].methods[0].record}\""
}

resource "auth0_custom_domain_verification" "apache_verification" {
  depends_on      = [cloudflare_dns_record.apache_verification_record]
  custom_domain_id = auth0_custom_domain.apache.id
  timeouts { create = "15m" }
}

resource "local_file" "apache-dot_env" {
  filename        = "${path.module}/../apache/.env"
  file_permission = "600"
  content         = <<-EOT
CNAME_API_KEY=${auth0_custom_domain_verification.apache_verification.cname_api_key}
AUTH0_EDGE_LOCATION=${auth0_custom_domain_verification.apache_verification.origin_domain_name}
DOMAIN_NAME=${local.apache_domain}
EOT
}

// -- tls --
resource "acme_registration" "apache_reg" {
  account_key_pem = tls_private_key.account_private_key.private_key_pem
  email_address   = "admin@${local.apache_domain}"
}

resource "acme_certificate" "apache_certificate" {
  account_key_pem           = acme_registration.apache_reg.account_key_pem
  common_name               = local.apache_domain
  subject_alternative_names = [local.apache_domain]

  dns_challenge {
    provider = "cloudflare"
    config = {
      CF_API_EMAIL   = var.cloudflare_email
      CF_API_KEY     = var.cloudflare_api_key
      CF_ZONE_API_KEY = var.cloudflare_zone_id
    }
  }

  min_days_remaining = 30
}

resource "local_file" "apache_private_key" {
  content         = acme_certificate.apache_certificate.private_key_pem
  filename        = "${path.cwd}/../apache/privkey.pem"
  file_permission = "600"
}

resource "local_file" "apache_fullchain" {
  content         = "${acme_certificate.apache_certificate.certificate_pem}${acme_certificate.apache_certificate.issuer_pem}"
  filename        = "${path.cwd}/../apache/fullchain.pem"
  file_permission = "600"
}
