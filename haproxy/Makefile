.PHONY: all run clean log

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

# Stop HAProxy
stop:
	@echo "Stopping HAProxy..."
	@if [ -f $(PWD)/haproxy.pid ]; then \
		kill -TERM `cat $(PWD)/haproxy.pid` || true; \
		rm -f $(PWD)/haproxy.pid; \
	else \
		echo "HAProxy is not running or PID file not found"; \
	fi

# Reload HAProxy configuration
reload:
	@echo "Reloading HAProxy configuration..."
	@if [ -f $(PWD)/haproxy.pid ]; then \
		haproxy -f $(PWD)/haproxy.cfg -p $(PWD)/haproxy.pid -sf `cat $(PWD)/haproxy.pid`; \
	else \
		echo "HAProxy is not running or PID file not found"; \
		$(MAKE) run; \
	fi

log:
	tail -f log/*

# Help
help:
	@echo "Available targets:"
	@echo "  run         - Run HAProxy on ports 8080 and 8443"
	@echo "  stop        - Stop HAProxy"
	@echo "  reload      - Reload HAProxy configuration"
	@echo "  clean       - Stop HAProxy and remove certificates"
	@echo "  help        - Show this help message"
