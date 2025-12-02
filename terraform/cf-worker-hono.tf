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
  hono_worker_path = "${path.module}/../cloudflare/worker-hono"
}

# Build Auth0 Actions (TypeScript -> dist/*.js) before using them
resource "null_resource" "build_auth0_actions" {
  # Re-run when sources change
  triggers = {
    pkg_hash             = filesha1("${local.hono_worker_path}/package.json")
    tsconfig_hash        = filesha1("${local.hono_worker_path}/tsconfig.json")
    sal_acntlink_ts_hash = filesha1("${local.hono_worker_path}/index.ts")
  }

  provisioner "local-exec" {
    command = "cd ${local.hono_worker_path} && npm run build"
  }
}


# Deploy the worker script
resource "cloudflare_workers_script" "auth0_custom_domain_hono" {
  account_id         = var.cloudflare_account_id
  script_name        = "auth0-custom-domain-hono"
  content_file       = "${local.hono_worker_path}/dist/index.js"
  content_sha256     = filesha256("${local.hono_worker_path}/dist/index.js")
  main_module        = "index.js"
  compatibility_date = "2025-12-01"

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
      text = auth0_custom_domain_verification.cf-worker-hono_verification.origin_domain_name
      namespace_id = ""
    },
    {
      name = "CNAME_API_KEY"
      type = "secret_text"
      text = auth0_custom_domain_verification.cf-worker-hono_verification.cname_api_key
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
resource "cloudflare_workers_custom_domain" "auth0_custom_domain_hono" {
  account_id  = var.cloudflare_account_id
  zone_id     = var.cloudflare_zone_id
  hostname    = "cf-hono.${var.tld}"
  //service     = local.worker_name
  service     = cloudflare_workers_script.auth0_custom_domain_hono.script_name
  environment = "production"
}


// -- dns
resource "auth0_custom_domain" "cf-worker-hono" {
  domain = "cf-hono.${var.tld}"
  type   = "self_managed_certs"
  custom_client_ip_header = "cf-connecting-ip"
  domain_metadata = {
    server = "cloudflare"
  }
}

resource "auth0_custom_domain_verification" "cf-worker-hono_verification" {
  depends_on = [cloudflare_dns_record.cf-worker-hono_verification_record]

  custom_domain_id = auth0_custom_domain.cf-worker-hono.id

  timeouts { create = "15m" }
}

resource "cloudflare_dns_record" "cf-worker-hono_verification_record" {
  zone_id = var.cloudflare_zone_id
  type = upper(auth0_custom_domain.cf-worker-hono.verification[0].methods[0].name)
  name = auth0_custom_domain.cf-worker-hono.verification[0].methods[0].domain
  ttl     = 300
  content = "\"${auth0_custom_domain.cf-worker-hono.verification[0].methods[0].record}\""
}

# Create .env file for Cloudflare Workers - run `make update-cf-secrets` to update Cloudflare
resource "local_file" "cf-worker-hono-dot_env" {
  filename = "${path.module}/../cloudflare/worker-hono/.env"
  file_permission = "600"
  content  = <<-EOT
CNAME_API_KEY=${auth0_custom_domain_verification.cf-worker-hono_verification.cname_api_key}
AUTH0_EDGE_LOCATION=${auth0_custom_domain_verification.cf-worker-hono_verification.origin_domain_name}
EOT
}
