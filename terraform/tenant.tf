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
