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

# Run Nginx with the configuration
run:
	@echo "Generating nginx.conf from template..."
	@envsubst '$$CNAME_API_KEY $$DOMAIN_NAME $$AUTH0_EDGE_LOCATION' < $(PWD)/nginx.conf.template > $(PWD)/nginx.conf
	@echo "Starting Nginx on ports 1080 (HTTP) and 1443 (HTTPS)..."
	@nginx -c $(PWD)/nginx.conf -p $(PWD)

log:
	@tail -f log/*

# Help
help:
	@echo "Available targets:"
	@echo "  all/start   - Run Nginx (default)"
	@echo "  run         - Run Nginx on ports 1080 and 1443"
	@echo "  log         - View logs"
	@echo "  help        - Show this help message"