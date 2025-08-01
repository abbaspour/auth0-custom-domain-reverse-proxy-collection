.PHONY: run log help

# Load environment variables
include .env
export

# Default target
all: run

start: run

# Run Nginx with the configuration
run:
	@echo "Generating nginx.conf from template..."
	@envsubst '$$CNAME_API_KEY $$DOMAIN_NAME $$AUTH0_EDGE_LOCATION' < $(PWD)/nginx.conf.template > $(PWD)/nginx.conf
	@echo "Starting Nginx on ports 8080 (HTTP) and 8443 (HTTPS)..."
	@nginx -c $(PWD)/nginx.conf -p $(PWD)

log:
	@tail -f log/*

# Help
help:
	@echo "Available targets:"
	@echo "  all/start   - Run Nginx (default)"
	@echo "  run         - Run Nginx on ports 8080 and 8443"
	@echo "  log         - View logs"
	@echo "  help        - Show this help message"