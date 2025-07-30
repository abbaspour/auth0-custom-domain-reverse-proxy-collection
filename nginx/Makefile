.PHONY: all cert letsencrypt renew-cert run clean log

# Load environment variables
include .env
export

# Default target
all: run

start: run

LETSENCRYPT_DIR = /etc/letsencrypt/live/$(DOMAIN_NAME)

check-certbot:
	@which certbot > /dev/null || (echo "Certbot not found. Please install certbot first." && exit 1)

letsencrypt: check-certbot
	@echo "Creating directories for Let's Encrypt..."
	@mkdir -p /var/www/letsencrypt/.well-known/acme-challenge
	@echo "Obtaining Let's Encrypt certificate for $(DOMAIN_NAME)..."
	@certbot certonly --standalone \
		--preferred-challenges http \
		--http-01-port 8080 \
		--non-interactive \
		--agree-tos \
		--email admin@$(DOMAIN_NAME) \
		-d $(DOMAIN_NAME)

renew-cert: check-certbot
	@echo "Renewing Let's Encrypt certificate for $(DOMAIN_NAME)..."
	@certbot renew
	@echo "Certificate renewal attempted. Check logs for details."

# Run Nginx with the configuration
run:
	@echo "Generating nginx.conf from template..."
	@envsubst '$$CNAME_API_KEY $$DOMAIN_NAME $$AUTH0_EDGE_LOCATION' < $(PWD)/nginx.conf.template > $(PWD)/nginx.conf
	@echo "Starting Nginx on ports 8080 (HTTP) and 8443 (HTTPS)..."
	@nginx -c $(PWD)/nginx.conf -p $(PWD)

# Stop Nginx
stop:
	@echo "Stopping Nginx..."
	@nginx -c $(PWD)/nginx.conf -s stop || true

# Reload Nginx configuration
reload:
	@echo "Reloading Nginx configuration..."
	@nginx -s reload

log:
	tail -f log/*

# Help
help:
	@echo "Available targets:"
	@echo "  all         - Generate certificate and run Nginx (default)"
	@echo "  letsencrypt - Obtain a Let's Encrypt SSL certificate (requires domain name in .env)"
	@echo "  renew-cert  - Renew Let's Encrypt SSL certificate"
	@echo "  run         - Run Nginx on ports 8080 and 8443"
	@echo "  stop        - Stop Nginx"
	@echo "  reload      - Reload Nginx configuration"
	@echo "  clean       - Stop Nginx and remove certificates"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Note: To use Let's Encrypt, set your domain name in the .env file (DOMAIN_NAME=yourdomain.com)"