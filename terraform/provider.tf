terraform {
  required_version = "~> 1.0"

  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.24.1"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 5.7.1"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.35"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "auth0" {
  domain                      = var.auth0_domain
  client_id                   = var.auth0_tf_client_id
  client_assertion_signing_alg = var.auth0_client_assertion_signing_alg
  client_assertion_private_key = file(var.auth0_client_assertion_private_key_file)
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "account_private_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}
