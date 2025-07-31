.PHONY: all cert letsencrypt renew-cert run stop reload log help

# Load environment variables
include .env
export

# Default target
all: run

start: run

# Define repository root (one level up from caddy directory)
REPO_ROOT = $(shell dirname $(PWD))

LETSENCRYPT_DIR = /etc/letsencrypt/live/$(DOMAIN_NAME)

letsencrypt:
	@echo "Obtaining Let's Encrypt certificate for $(DOMAIN_NAME)..."
	@$(REPO_ROOT)/letsencrypt/cert.sh $(DOMAIN_NAME)

renew-cert:
	@echo "Renewing Let's Encrypt certificate for $(DOMAIN_NAME)..."
	@$(REPO_ROOT)/letsencrypt/renew.sh $(DOMAIN_NAME)

# Create log directory
prepare:
	@mkdir -p $(PWD)/log

# Run Caddy with the configuration
run: prepare
	@mkdir -p $(PWD)/log
	@echo "Starting Caddy on ports 8080 (HTTP) and 8443 (HTTPS)..."
	@caddy start --config $(PWD)/Caddyfile --adapter caddyfile --envfile $(PWD)/.env 2>&1 | tee $(PWD)/log/caddy.log &
	@echo $! > $(PWD)/caddy.pid

# Stop Caddy
stop:
	@echo "Stopping Caddy..."
	@if [ -f $(PWD)/caddy.pid ]; then \
		kill -TERM `cat $(PWD)/caddy.pid` || true; \
		rm -f $(PWD)/caddy.pid; \
	else \
		echo "Caddy is not running or PID file not found"; \
	fi

# Reload Caddy configuration
reload:
	@echo "Reloading Caddy configuration..."
	@if [ -f $(PWD)/caddy.pid ]; then \
		caddy reload --config $(PWD)/Caddyfile --adapter caddyfile --envfile $(PWD)/.env; \
	else \
		echo "Caddy is not running or PID file not found"; \
		$(MAKE) run; \
	fi

log:
	@tail -f $(PWD)/log/*

# Help
help:
	@echo "Available targets:"
	@echo "  all         - Generate certificate and run Caddy (default)"
	@echo "  letsencrypt - Obtain a Let's Encrypt SSL certificate using scripts in ../letsencrypt/ (requires domain name in .env)"
	@echo "  renew-cert  - Renew Let's Encrypt SSL certificate using scripts in ../letsencrypt/"
	@echo "  run         - Run Caddy on ports 8080 and 8443"
	@echo "  stop        - Stop Caddy"
	@echo "  reload      - Reload Caddy configuration"
	@echo "  log         - View logs"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Note: To use Let's Encrypt, set your domain name in the .env file (DOMAIN_NAME=yourdomain.com)"
	@echo "      Let's Encrypt scripts are in the top-level letsencrypt/ directory"