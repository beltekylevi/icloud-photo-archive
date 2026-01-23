include configs/variables/.env

ICLOUDPD_VERSION := $(shell cat configs/versions/icloudpd)

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
