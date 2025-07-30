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

