#!/bin/bash
# renew.sh - Script to renew a Let's Encrypt certificate for a domain

# Check if domain parameter is provided
if [ -z "$1" ]; then
    echo "Error: Domain name is required."
    echo "Usage: $0 <domain>"
    exit 1
fi

DOMAIN_NAME=$1
LETSENCRYPT_DIR="/etc/letsencrypt/live/$DOMAIN_NAME"

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Error: Certbot not found. Please install certbot first."
    exit 1
fi

# Check if certificate exists
if [ ! -d "$LETSENCRYPT_DIR" ]; then
    echo "Error: Certificate directory not found for $DOMAIN_NAME."
    echo "Please obtain a certificate first using cert.sh."
    exit 1
fi

# Renew Let's Encrypt certificate
echo "Renewing Let's Encrypt certificate for $DOMAIN_NAME..."
certbot renew --cert-name $DOMAIN_NAME

# Check if renewal was successful
if [ $? -eq 0 ]; then
    echo "Certificate renewal attempted for $DOMAIN_NAME."
    echo "Check certbot logs for details."
else
    echo "Failed to renew certificate for $DOMAIN_NAME."
    exit 1
fi