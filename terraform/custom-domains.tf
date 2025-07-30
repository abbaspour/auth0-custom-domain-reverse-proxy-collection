locals {
  tld = "smcd.authlab.work"
}

// -- lab --
resource "cloudflare_dns_record" "lab-cname-record" {
  zone_id = var.cloudflare_zone_id
  type = "CNAME"
  name = "lab.${local.tld}"
  ttl     = 300
  content = var.lab-hostname
}

// -- cloudflare worker --
resource "auth0_custom_domain" "cf-worker-fetch" {
  domain = "cf-fetch.${local.tld}"
  type   = "self_managed_certs"
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

// -- nginx --
resource "cloudflare_dns_record" "nginx" {
  zone_id = var.cloudflare_zone_id
  type = "CNAME"
  name = "nginx.${local.tld}"
  ttl     = 300
  content = "lab.${local.tld}"
}

resource "auth0_custom_domain" "nginx" {
  domain = "nginx.${local.tld}"
  type   = "self_managed_certs"
}

resource "cloudflare_dns_record" "nginx_verification_record" {
  zone_id = var.cloudflare_zone_id
  type = upper(auth0_custom_domain.nginx.verification[0].methods[0].name)
  name = auth0_custom_domain.nginx.verification[0].methods[0].domain
  ttl     = 300
  content = "\"${auth0_custom_domain.nginx.verification[0].methods[0].record}\""
}

resource "auth0_custom_domain_verification" "nginx_verification" {
  depends_on = [cloudflare_dns_record.nginx_verification_record]
  custom_domain_id = auth0_custom_domain.nginx.id
  timeouts { create = "15m" }
}

resource "local_file" "nginx-dot_env" {
  filename = "${path.module}/../nginx/.env"
  file_permission = "600"
  content  = <<-EOT
CNAME_API_KEY=${auth0_custom_domain_verification.nginx_verification.cname_api_key}
AUTH0_EDGE_LOCATION=${auth0_custom_domain_verification.nginx_verification.origin_domain_name}
DOMAIN_NAME=nginx.${local.tld}
EOT
}
