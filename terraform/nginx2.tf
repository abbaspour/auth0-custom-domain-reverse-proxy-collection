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
  nginx2_domain = "nginx2.${var.tld}"
}

// -- nginx server --
resource "cloudflare_dns_record" "nginx2" {
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = local.nginx2_domain
  ttl     = 300
  content = "lab.${var.tld}"
}

resource "local_file" "nginx2-dot_env" {
  filename        = "${path.module}/../nginx2/.env"
  file_permission = "600"
  content         = <<-EOT
CNAME_API_KEY=${auth0_custom_domain_verification.nginx_verification.cname_api_key}
AUTH0_EDGE_LOCATION=${auth0_custom_domain_verification.nginx_verification.origin_domain_name}
DOMAIN_NAME=${local.nginx2_domain}
EOT
}

// -- tls --
resource "acme_registration" "nginx2_reg" {
  account_key_pem = tls_private_key.account_private_key.private_key_pem
  email_address   = "admin@${local.nginx2_domain}"
}

resource "acme_certificate" "nginx2_certificate" {
  account_key_pem           = acme_registration.nginx2_reg.account_key_pem
  common_name               = local.nginx2_domain
  subject_alternative_names = [local.nginx2_domain]

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


resource "local_file" "nginx2_private_key" {
  content = acme_certificate.nginx2_certificate.private_key_pem
  filename = "${path.cwd}/../nginx2/privkey.pem"
  file_permission = "600"
}

resource "local_file" "nginx2_fullchain" {
  content  = "${acme_certificate.nginx2_certificate.certificate_pem}${acme_certificate.nginx2_certificate.issuer_pem}"
  filename = "${path.cwd}/../nginx2/fullchain.pem"
  file_permission = "600"
}
