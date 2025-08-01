.PHONY: run log help

# Load environment variables
include .env
export

# Default target
all: run

start: run

# Create log directory
prepare:
	@mkdir -p $(PWD)/log

# Run Caddy with the configuration
run: prepare
	@mkdir -p $(PWD)/log
	@echo "Starting Caddy on ports 8080 (HTTP) and 8443 (HTTPS)..."
	@caddy run --config $(PWD)/Caddyfile --adapter caddyfile --envfile $(PWD)/.env 2>&1 | tee $(PWD)/log/caddy.log
	@echo $! > $(PWD)/caddy.pid

log:
	@tail -f $(PWD)/log/*

# Help
help:
	@echo "Available targets:"
	@echo "  all/start   - Run Caddy (default)"
	@echo "  run         - Run Caddy on ports 8080 and 8443"
	@echo "  log         - View logs"
	@echo "  help        - Show this help message"