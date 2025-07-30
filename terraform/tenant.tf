# sample app
resource "auth0_client" "jwt-io" {
  name                       = "JWT.io"
  description                = "JWT.io SPA application"
  app_type                   = "spa"
  is_first_party             = true
  oidc_conformant            = true

  callbacks = [
    "https://jwt.io"
  ]

  allowed_logout_urls = []
  web_origins = []

  grant_types = [
    "implicit",
  ]
}

output "jwt-io-client_id" {
  value = auth0_client.jwt-io.client_id
}

# sample user
resource "auth0_user" "user1" {
  connection_name = "Username-Password-Authentication"
  email = "user1@atko.email"
  password = var.sample-user-password
}