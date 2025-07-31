.PHONY: all cert letsencrypt renew-cert run clean log

# Load environment variables
include .env
export

# Default target
all: run

start: run

# Define repository root (one level up from nginx directory)
REPO_ROOT = $(shell dirname $(PWD))

LETSENCRYPT_DIR = /etc/letsencrypt/live/$(DOMAIN_NAME)

letsencrypt:
	@echo "Obtaining Let's Encrypt certificate for $(DOMAIN_NAME)..."
	@$(REPO_ROOT)/letsencrypt/cert.sh $(DOMAIN_NAME)

renew-cert:
	@echo "Renewing Let's Encrypt certificate for $(DOMAIN_NAME)..."
	@$(REPO_ROOT)/letsencrypt/renew.sh $(DOMAIN_NAME)

# Run Nginx with the configuration
run:
	@echo "Generating nginx.conf from template..."
	@envsubst '$$CNAME_API_KEY $$DOMAIN_NAME $$AUTH0_EDGE_LOCATION' < $(PWD)/nginx.conf.template > $(PWD)/nginx.conf
	@echo "Starting Nginx on ports 8080 (HTTP) and 8443 (HTTPS)..."
	@nginx -c $(PWD)/nginx.conf -p $(PWD)

# Stop Nginx
stop:
	@echo "Stopping Nginx..."
	@nginx -c $(PWD)/nginx.conf -s stop || true

# Reload Nginx configuration
reload:
	@echo "Reloading Nginx configuration..."
	@nginx -s reload

log:
	tail -f log/*

# Help
help:
	@echo "Available targets:"
	@echo "  all         - Generate certificate and run Nginx (default)"
	@echo "  letsencrypt - Obtain a Let's Encrypt SSL certificate using scripts in ../letsencrypt/ (requires domain name in .env)"
	@echo "  renew-cert  - Renew Let's Encrypt SSL certificate using scripts in ../letsencrypt/"
	@echo "  run         - Run Nginx on ports 8080 and 8443"
	@echo "  stop        - Stop Nginx"
	@echo "  reload      - Reload Nginx configuration"
	@echo "  clean       - Stop Nginx and remove certificates"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Note: To use Let's Encrypt, set your domain name in the .env file (DOMAIN_NAME=yourdomain.com)"
	@echo "      Let's Encrypt scripts are now in the top-level letsencrypt/ directory"