#!/bin/bash
# cert.sh - Script to obtain a Let's Encrypt certificate for a domain

# Check if domain parameter is provided
if [ -z "$1" ]; then
    echo "Error: Domain name is required."
    echo "Usage: $0 <domain>"
    exit 1
fi

DOMAIN_NAME=$1

WEBROOT="./domains"
LETSENCRYPT_DIR=".${WEBROOT}/$DOMAIN_NAME"

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Error: Certbot not found. Please install certbot first."
    exit 1
fi

# Create directories for Let's Encrypt
#echo "Creating directories for Let's Encrypt..."
#mkdir -p "./.well-known/acme-challenge"

# Obtain Let's Encrypt certificate
echo "Obtaining Let's Encrypt certificate for $DOMAIN_NAME..."
certbot certonly --standalone \
    --preferred-challenges http \
    --http-01-port 8080 \
    --non-interactive \
    --agree-tos \
    --email admin@$DOMAIN_NAME \
    --webroot-path "${WEBROOT}" \
    --work-dir . \
    -d $DOMAIN_NAME

# Check if certificate was obtained successfully
if [ -d "$LETSENCRYPT_DIR" ]; then
    echo "Certificate obtained successfully for $DOMAIN_NAME."
    echo "Certificate location: $LETSENCRYPT_DIR"
else
    echo "Failed to obtain certificate for $DOMAIN_NAME."
    exit 1
fi