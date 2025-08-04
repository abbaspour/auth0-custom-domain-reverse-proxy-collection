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

// -- cloudflare worker --
locals {
  worker_name = "auth0-custom-domain-fetch"
  worker_path = "${path.module}/../cloudflare/worker-fetch"
}

# Deploy the worker script
resource "cloudflare_workers_script" "auth0_custom_domain_fetch" {
  account_id         = var.cloudflare_account_id
  script_name        = local.worker_name
  content_file       = "${local.worker_path}/index.mjs"
  content_sha256     = filesha256("${local.worker_path}/index.mjs")
  main_module        = "index.mjs"
  compatibility_date = "2025-07-29"

  /*
  observability = {
    enabled            = true
    head_sampling_rate = 1
  }
  */

  bindings = [
    {
      name = "AUTH0_EDGE_LOCATION"
      type = "plain_text"
      text = auth0_custom_domain_verification.cf-worker-fetch_verification.origin_domain_name
      namespace_id = ""
    },
    {
      name = "CNAME_API_KEY"
      type = "secret_text"
      text = auth0_custom_domain_verification.cf-worker-fetch_verification.cname_api_key
      namespace_id = ""
    }
  ]

  placement = {
    mode = "smart"
  }

  migrations = {}

  lifecycle {
    ignore_changes = [
      placement
    ]
  }
}

# Configure custom domain for the worker
resource "cloudflare_workers_custom_domain" "auth0_custom_domain_fetch" {
  account_id  = var.cloudflare_account_id
  zone_id     = var.cloudflare_zone_id
  hostname    = "cf-fetch.${var.tld}"
  service     = local.worker_name
  environment = "production"
}


// -- dns
resource "auth0_custom_domain" "cf-worker-fetch" {
  domain = "cf-fetch.${var.tld}"
  type   = "self_managed_certs"
  domain_metadata = {
    server = "cloudflare"
  }
}

resource "auth0_custom_domain_verification" "cf-worker-fetch_verification" {
  depends_on = [cloudflare_dns_record.cf-worker-fetch_verification_record]

  custom_domain_id = auth0_custom_domain.cf-worker-fetch.id

  timeouts { create = "15m" }
}

resource "cloudflare_dns_record" "cf-worker-fetch_verification_record" {
  zone_id = var.cloudflare_zone_id
  type = upper(auth0_custom_domain.cf-worker-fetch.verification[0].methods[0].name)
  name = auth0_custom_domain.cf-worker-fetch.verification[0].methods[0].domain
  ttl     = 300
  content = "\"${auth0_custom_domain.cf-worker-fetch.verification[0].methods[0].record}\""
}

# Create .env file for Cloudflare Workers - run `make update-cf-secrets` to update Cloudflare
resource "local_file" "cf-worker-fetch-dot_env" {
  filename = "${path.module}/../cloudflare/worker-fetch/.env"
  file_permission = "600"
  content  = <<-EOT
CNAME_API_KEY=${auth0_custom_domain_verification.cf-worker-fetch_verification.cname_api_key}
AUTH0_EDGE_LOCATION=${auth0_custom_domain_verification.cf-worker-fetch_verification.origin_domain_name}
EOT
}
