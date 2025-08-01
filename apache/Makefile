.PHONY: all cert letsencrypt renew-cert run clean log

# Load environment variables
include .env
export

# Default target
all: run

start: run

# Define repository root (one level up from apache directory)
REPO_ROOT = $(shell dirname $(PWD))

LETSENCRYPT_DIR = /etc/letsencrypt/live/$(DOMAIN_NAME)

letsencrypt:
	@echo "Obtaining Let's Encrypt certificate for $(DOMAIN_NAME)..."
	@$(REPO_ROOT)/letsencrypt/cert.sh $(DOMAIN_NAME)

renew-cert:
	@echo "Renewing Let's Encrypt certificate for $(DOMAIN_NAME)..."
	@$(REPO_ROOT)/letsencrypt/renew.sh $(DOMAIN_NAME)

# Run Apache with the configuration
run:
	@echo "Generating apache.conf from template..."
	@envsubst '$$CNAME_API_KEY $$DOMAIN_NAME $$AUTH0_EDGE_LOCATION' < $(PWD)/apache.conf.template > $(PWD)/apache.conf
	@echo "Starting Apache on ports 8080 (HTTP) and 8443 (HTTPS)..."
	@mkdir -p $(PWD)/log
	@apache2 -f $(PWD)/apache.conf -d $(PWD) -D FOREGROUND

# Stop Apache
stop:
	@echo "Stopping Apache..."
	@if [ -f $(PWD)/httpd.pid ]; then \
		kill -TERM `cat $(PWD)/httpd.pid` || true; \
	else \
		echo "Apache is not running or PID file not found"; \
	fi

# Reload Apache configuration
reload:
	@echo "Reloading Apache configuration..."
	@if [ -f $(PWD)/httpd.pid ]; then \
		kill -HUP `cat $(PWD)/httpd.pid`; \
	else \
		echo "Apache is not running or PID file not found"; \
	fi

log:
	tail -f log/*

# Help
help:
	@echo "Available targets:"
	@echo "  all         - Generate certificate and run Apache (default)"
	@echo "  letsencrypt - Obtain a Let's Encrypt SSL certificate using scripts in ../letsencrypt/ (requires domain name in .env)"
	@echo "  renew-cert  - Renew Let's Encrypt SSL certificate using scripts in ../letsencrypt/"
	@echo "  run         - Run Apache on ports 8080 and 8443"
	@echo "  stop        - Stop Apache"
	@echo "  reload      - Reload Apache configuration"
	@echo "  clean       - Stop Apache and remove certificates"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Note: To use Let's Encrypt, set your domain name in the .env file (DOMAIN_NAME=yourdomain.com)"
	@echo "      Let's Encrypt scripts are now in the top-level letsencrypt/ directory"