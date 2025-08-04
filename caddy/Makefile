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