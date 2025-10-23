.PHONY: compile build deploy lint format

SECRETS_FILE = .env

build:
	npm run build

compile:
	npm run compile

apply: deploy

deploy:
	npm run deploy

lint:
	npm run lint

fix:
	npm run lint:fix

format:
	npm run format

log:
	npx wrangler tail

update-cf-secrets:
	npx wrangler secret bulk $(SECRETS_FILE)