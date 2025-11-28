# Nginx Reverse Proxy for Auth0 Custom Domain

This directory contains the configuration for running an Nginx reverse proxy for Auth0 custom domains.
This a special case when RP in which we point to a different origin (for `nginx/`) and rewrite headers and cookies.

> **Tested with Nginx version:** 1.24.0

[Return to main README](../README.md)

## Prerequisites

- Nginx installed on your system
- A valid domain name pointing to your server
- Environment variables set in `.env` file (created by Terraform)

## Configuration

### Environment Variables

The configuration uses environment variables defined in the `.env` file:

- `CNAME_API_KEY`: The API key for Auth0 custom domain
- `AUTH0_EDGE_LOCATION`: The Auth0 edge location URL
- `DOMAIN_NAME`: Your custom domain name

These variables are automatically set in the `.env` file by Terraform.

## Setup

1. Run Terraform to create the Auth0 custom domain and generate the `.env` file:
   ```
   cd ../terraform
   terraform apply
   ```

2. Start Nginx:
   ```
   make run
   ```

### Managing Nginx

- **Start Nginx**: `make run` or `make start`
- **Stop Nginx**: `make stop`
- **Reload Configuration**: `make reload`
- **View Logs**: `make log`
- **Clean Up**: `make clean`

## How It Works

- SSL/TLS certificates are managed by Terraform
- HTTP requests (port 8080) are redirected to HTTPS (port 8443)
- Nginx proxies requests to Auth0 with the required headers

## Troubleshooting

- Check the logs with `make log`
- Ensure the `.env` file exists and contains the required variables
- Verify that your domain is correctly pointing to your server