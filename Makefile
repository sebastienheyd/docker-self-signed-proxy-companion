.PHONY:help build
.DEFAULT_GOAL=help

help:
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build docker image
	docker build --no-cache -t sebastienheyd/self-signed-proxy-companion .

buildx: ## Build multiarch and push docker image
	docker buildx build --push --no-cache --platform linux/arm64,linux/amd64 -t sebastienheyd/self-signed-proxy-companion:latest .
