#!/bin/bash
# cert.sh - Script to obtain a Let's Encrypt certificate for a domain

# Check if domain parameter is provided
if [ -z "$1" ]; then
    echo "Error: Domain name is required."
    echo "Usage: $0 <domain>"
    exit 1
fi

DOMAIN_NAME=$1
LETSENCRYPT_DIR="/etc/letsencrypt/live/${DOMAIN_NAME}"

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Error: Certbot not found. Please install certbot first."
    exit 1
fi

# Obtain Let's Encrypt certificate
echo "Obtaining Let's Encrypt certificate for $DOMAIN_NAME..."
certbot certonly --standalone \
    --preferred-challenges http \
    --http-01-port 8080 \
    --non-interactive \
    --agree-tos \
    --email admin@"$DOMAIN_NAME" \
    -d "$DOMAIN_NAME"

# Check if certificate was obtained successfully
if [ -d "$LETSENCRYPT_DIR" ]; then
    echo "Certificate obtained successfully for $DOMAIN_NAME."
    echo "Certificate location: $LETSENCRYPT_DIR"
else
    echo "Failed to obtain certificate for $DOMAIN_NAME."
    exit 1
fi

# fullchain + privkey for haproxy
cat "${LETSENCRYPT_DIR}/fullchain.pem" "${LETSENCRYPT_DIR}/privkey.pem" > "${LETSENCRYPT_DIR}/fullchain-privkey.pem"