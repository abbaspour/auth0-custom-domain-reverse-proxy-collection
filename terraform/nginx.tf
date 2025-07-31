// -- nginx --
resource "cloudflare_dns_record" "nginx" {
  zone_id = var.cloudflare_zone_id
  type = "CNAME"
  name = "nginx.${var.tld}"
  ttl     = 300
  content = "lab.${var.tld}"
}

resource "auth0_custom_domain" "nginx" {
  domain = "nginx.${var.tld}"
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
DOMAIN_NAME=nginx.${var.tld}
EOT
}
