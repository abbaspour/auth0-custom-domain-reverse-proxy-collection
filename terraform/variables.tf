## auth0
variable "auth0_domain" {
  type = string
  description = "Auth0 Domain"
}

variable "auth0_tf_client_id" {
  type = string
  description = "Auth0 TF provider client_id"
}

variable "auth0_client_assertion_private_key_file" {
  type = string
  description = "Path to the private key file for client assertion"
  default = "terraform-jwt-ca-private.pem"
}

variable "auth0_client_assertion_signing_alg" {
  type = string
  description = "Algorithm used for signing client assertion"
  default = "PS256"
}

variable "sample-user-password" {
  type = string
  description = "Sample user password"
  sensitive = true
}

## cloudflare
variable "cloudflare_api_key" {
  description = "Cloudflare API Key"
  type = string
  sensitive = true
}

variable "cloudflare_email" {
  description = "Cloudflare Account Email"
  type = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the domain"
  type = string
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type = string
}
