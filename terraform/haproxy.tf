// -- haproxy --
resource "cloudflare_dns_record" "haproxy" {
  zone_id = var.cloudflare_zone_id
  type = "CNAME"
  name = "haproxy.${var.tld}"
  ttl     = 300
  content = "lab.${var.tld}"
}

resource "auth0_custom_domain" "haproxy" {
  domain = "haproxy.${var.tld}"
  type   = "self_managed_certs"
}

resource "cloudflare_dns_record" "haproxy_verification_record" {
  zone_id = var.cloudflare_zone_id
  type = upper(auth0_custom_domain.haproxy.verification[0].methods[0].name)
  name = auth0_custom_domain.haproxy.verification[0].methods[0].domain
  ttl     = 300
  content = "\"${auth0_custom_domain.haproxy.verification[0].methods[0].record}\""
}

resource "auth0_custom_domain_verification" "haproxy_verification" {
  depends_on = [cloudflare_dns_record.haproxy_verification_record]
  custom_domain_id = auth0_custom_domain.haproxy.id
  timeouts { create = "15m" }
}

resource "local_file" "haproxy-dot_env" {
  filename = "${path.module}/../haproxy/.env"
  file_permission = "600"
  content  = <<-EOT
CNAME_API_KEY=${auth0_custom_domain_verification.haproxy_verification.cname_api_key}
AUTH0_EDGE_LOCATION=${auth0_custom_domain_verification.haproxy_verification.origin_domain_name}
DOMAIN_NAME=haproxy.${var.tld}
EOT
}