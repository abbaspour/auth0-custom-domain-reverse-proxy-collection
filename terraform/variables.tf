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

## lab
variable "lab-hostname" {
  description = "DNS record for lab environment, running nginx, haproxy, etc locally and port forwarding"
  type = string
}

## shared custom domain top level
variable "tld" {
  description = "common DNS TLD for all custom domains"
  type = string
  default = "smcd.authlab.work"
}

## aws
variable "aws_region" {
  description = "AWS region to deploy API Gateway"
  type        = string
  default     = "ap-southeast-2"  # sydney
}