.PHONY: run log help

# Load environment variables
include .env
export

# Default target
all: run

start: run

# Run Apache with the configuration
run:
	@echo "Generating apache.conf from template..."
	@envsubst '$$CNAME_API_KEY $$DOMAIN_NAME $$AUTH0_EDGE_LOCATION' < $(PWD)/apache.conf.template > $(PWD)/apache.conf
	@echo "Starting Apache on ports 8080 (HTTP) and 8443 (HTTPS)..."
	@mkdir -p $(PWD)/log
	@apache2 -f $(PWD)/apache.conf -d $(PWD) -D FOREGROUND

log:
	@tail -f log/*

# Help
help:
	@echo "Available targets:"
	@echo "  all/start   - Run Apache (default)"
	@echo "  run         - Run Apache on ports 8080 and 8443"
	@echo "  log         - View logs"
	@echo "  help        - Show this help message"