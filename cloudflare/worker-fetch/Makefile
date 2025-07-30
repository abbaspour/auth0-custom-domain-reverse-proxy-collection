publish: deploy

SECRETS_FILE = '.env'

deploy:
	wrangler deploy

log:
	wrangler tail

update-cf-secrets:
	npx wrangler secret bulk $(SECRETS_FILE)