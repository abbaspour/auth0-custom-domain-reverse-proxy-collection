# Nginx with Let's Encrypt SSL

This directory contains the configuration for running an Nginx reverse proxy with SSL support, including Let's Encrypt for free valid SSL certificates.

> **Tested with Nginx version:** 1.24.0

[Return to main README](../README.md)

## Prerequisites

- Nginx installed on your system
- Certbot installed for Let's Encrypt support (only needed if you want to use Let's Encrypt)
- A valid domain name pointing to your server (required for Let's Encrypt)

## Configuration

### Environment Variables

The configuration uses environment variables defined in the `.env` file:

- `CNAME_API_KEY`: The API key for Auth0 custom domain
- `AUTH0_EDGE_LOCATION`: The Auth0 edge location URL
- `DOMAIN_NAME`: Your domain name (required for Let's Encrypt)

## Usage

### Setting Up

1. Edit the `.env` file to set your domain name:
   ```
   DOMAIN_NAME=yourdomain.com
   ```

2. Choose your SSL option:

   - For production (Let's Encrypt):
     ```
     make letsencrypt
     ```

3. Start Nginx:
   ```
   make run
   ```

### Managing Nginx

- **Start Nginx**: `make run` or `make start`
- **Stop Nginx**: `make stop`
- **Reload Configuration**: `make reload`
- **View Logs**: `make log`
- **Clean Up**: `make clean`

### Let's Encrypt Certificate Renewal

Let's Encrypt certificates are valid for 90 days. To renew:

```
make renew-cert
```

Consider setting up a cron job to automatically renew certificates:

```
0 0 1 * * cd /path/to/nginx/directory && make renew-cert
```

## How It Works

- The Nginx configuration automatically detects and uses Let's Encrypt certificates if available
- If Let's Encrypt certificates are not found, it falls back to self-signed certificates
- HTTP requests (port 8080) are redirected to HTTPS (port 8443)
- Let's Encrypt verification is handled through the `/.well-known/acme-challenge/` path

## Troubleshooting

- If Let's Encrypt verification fails, ensure your domain is correctly pointing to your server
- Check that port 8080 is accessible from the internet for Let's Encrypt verification
- Review the Nginx logs with `make log` for any errors