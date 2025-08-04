# Apache Reverse Proxy for Auth0 Custom Domain

This directory contains the configuration for running an Apache reverse proxy for Auth0 custom domains.

> **Tested with Apache version:** 2.4.58

[Return to main README](../README.md)

## Prerequisites

- Apache HTTP Server installed on your system
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

2. Start Apache:
   ```
   make run
   ```

### Managing Apache

- **Start Apache**: `make run` or `make start`
- **Stop Apache**: `make stop`
- **Reload Configuration**: `make reload`
- **View Logs**: `make log`
- **Clean Up**: `make clean`

## How It Works

- SSL/TLS certificates are managed by Terraform
- HTTP requests (port 8080) are redirected to HTTPS (port 8443)
- Apache proxies requests to Auth0 with the required headers

## Troubleshooting

- Check the logs with `make log`
- Ensure the `.env` file exists and contains the required variables
- Verify that your domain is correctly pointing to your server
- Make sure all required Apache modules are enabled (ssl, proxy, headers, rewrite)