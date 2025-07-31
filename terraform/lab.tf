// -- lab --
resource "cloudflare_dns_record" "lab-cname-record" {
  zone_id = var.cloudflare_zone_id
  type = "CNAME"
  name = "lab.${var.tld}"
  ttl     = 300
  content = var.lab-hostname
}

