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
