.PHONY:help build
.DEFAULT_GOAL=help

help:
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build docker image
	docker build --no-cache -t sebastienheyd/self-signed-proxy-companion .

multiarch: ## Install multiarch
	docker pull multiarch/qemu-user-static
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx rm builder
	docker buildx create --name builder --driver docker-container --use
	docker buildx inspect --bootstrap

buildx: ## Build multiarch
	docker buildx build --no-cache --platform linux/arm64,linux/amd64 -t sebastienheyd/self-signed-proxy-companion:latest .
	docker buildx build --load -t sebastienheyd/self-signed-proxy-companion:latest .

buildxpush: ## Build multiarch and push docker image
	docker buildx build --push --no-cache --platform linux/arm64,linux/amd64 -t sebastienheyd/self-signed-proxy-companion:latest .
