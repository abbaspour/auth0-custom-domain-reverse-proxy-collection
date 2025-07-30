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
      name = "CNAME_API_KEY"
      type = "secret_text"
      text = auth0_custom_domain_verification.cf-worker-fetch_verification.cname_api_key
    },
    {
      name = "AUTH0_EDGE_LOCATION"
      type = "plain_text"
      text = auth0_custom_domain_verification.cf-worker-fetch_verification.origin_domain_name
    }
  ]
}

# Configure custom domain for the worker
resource "cloudflare_workers_custom_domain" "auth0_custom_domain_fetch" {
  account_id  = var.cloudflare_account_id
  zone_id     = var.cloudflare_zone_id
  hostname    = "cf-fetch.${local.tld}"
  service     = local.worker_name
  environment = "production"
}

