include configs/variables/.env

ICLOUDPD_VERSION := $(shell cat configs/versions/icloudpd)
IMMICH_CLI_VERSION := $(shell cat configs/versions/immich-cli)

help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

download-photos: ## Download photos from iCloud using icloudpd
	docker run --interactive --tty --rm \
		--env TZ=$(TZ) \
		--volume $(ICLOUD_PHOTOS_DIR):/data \
		--volume $(ICLOUD_AUTH_DIR):/auth \
		icloudpd/icloudpd:$(ICLOUDPD_VERSION) icloudpd \
		--log-level info --domain com --directory /data --cookie-directory /auth \
		--username $(ICLOUD_USERNAME) --size original --skip-live-photos

prune-photos: ## Download and delete photos from iCloud using icloudpd
	docker run --interactive --tty --rm \
		--env TZ=$(TZ) \
		--volume $(ICLOUD_PHOTOS_DIR):/data \
		--volume $(ICLOUD_AUTH_DIR):/auth \
		icloudpd/icloudpd:$(ICLOUDPD_VERSION) icloudpd \
		--log-level info --domain com --directory /data --cookie-directory /auth \
		--username $(ICLOUD_USERNAME) --size original --skip-live-photos \
		--skip-photos --keep-icloud-recent-days 365

upload-photos: ## Upload photos to Immich using immich-cli
	docker run --interactive --tty --rm \
		--env IMMICH_INSTANCE_URL=$(IMMICH_INSTANCE_URL) \
		--env IMMICH_API_KEY=$(IMMICH_API_KEY) \
		--network host \
		--volume $(ICLOUD_PHOTOS_DIR):/import:ro \
		ghcr.io/immich-app/immich-cli:$(IMMICH_CLI_VERSION) upload \
		--recursive /import
