.PHONY: run log help

# Load environment variables
include .env
export

# Default target
all: run

start: run

HAPROXY_ADMIN_PASS := $(shell tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 12)

# Run HAProxy with the configuration
run:
	@echo "Generating haproxy.cfg from template..."
	@echo "HAPROXY_ADMIN_PASS:" $(HAPROXY_ADMIN_PASS)
	@export HAPROXY_ADMIN_PASS=$(HAPROXY_ADMIN_PASS) && \
	envsubst '$$CNAME_API_KEY $$DOMAIN_NAME $$AUTH0_EDGE_LOCATION $$HAPROXY_ADMIN_PASS' < $(PWD)/haproxy.cfg.template > $(PWD)/haproxy.cfg
	@echo "Starting HAProxy on ports 8080 (HTTP) and 8443 (HTTPS)..."
	@haproxy -f $(PWD)/haproxy.cfg -p $(PWD)/haproxy.pid -db

log:
	@mkdir -p $(PWD)/log
	@touch $(PWD)/log/haproxy.log
	@tail -f log/*

# Help
help:
	@echo "Available targets:"
	@echo "  all/start   - Run HAProxy (default)"
	@echo "  run         - Run HAProxy on ports 8080 and 8443"
	@echo "  log         - View logs"
	@echo "  help        - Show this help message"
