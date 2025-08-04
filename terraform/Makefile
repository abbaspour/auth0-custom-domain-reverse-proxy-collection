# Copyright 2025 Auth0 Product Architecture Team
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.PHONY: init plan apply destroy

all: plan

generate-keys: terraform-jwt-ca-public.pem

terraform-jwt-ca-private.pem:
	@echo "Generating PS256 key pair for Auth0 client assertion..."
	openssl genpkey -algorithm RSA -out terraform-jwt-ca-private.pem -pkeyopt rsa_keygen_bits:2048

terraform-jwt-ca-public.pem: terraform-jwt-ca-private.pem
	openssl rsa -pubout -in terraform-jwt-ca-private.pem -out terraform-jwt-ca-public.pem
	@echo "Keys generated: terraform-jwt-ca-private.pem and terraform-jwt-ca-public.pem"

init:
	terraform init

plan:
	terraform plan -out=tfplan

apply: init
	terraform apply -auto-approve

destroy: init
	terraform destroy -auto-approve

