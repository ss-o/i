GOCMD=go
BINARY_NAME=i
VERSION=1.0.0
SERVICE_PORT=3000
DOCKER_REGISTRY=ghcr.io
EXPORT_RESULT=true

#YELLOW := $(shell tput -Txterm setaf 3)
#WHITE  := $(shell tput -Txterm setaf 7)
#CYAN   := $(shell tput -Txterm setaf 6)
#RESET  := $(shell tput -Txterm sgr0)

clean:
	rm -fr ./bin

build:
	mkdir -p ./bin
	GO111MODULE=on $(GOCMD) build -mod vendor -o ./bin/$(BINARY_NAME)

vendor:
	$(GOCMD) mod vendor

watch:
	$(eval PACKAGE_NAME=$(shell head -n 1 go.mod | cut -d ' ' -f2))
	docker run -it --rm -w /go/src/$(PACKAGE_NAME) -v $(shell pwd):/go/src/$(PACKAGE_NAME) -p $(SERVICE_PORT):$(SERVICE_PORT) i

## Docker:
docker-build: ## Use the dockerfile to build the container
	docker build --rm --tag $(BINARY_NAME) .

docker-release: ## Release the container with tag latest and version
	docker tag $(BINARY_NAME) $(DOCKER_REGISTRY)$(BINARY_NAME):latest
	docker tag $(BINARY_NAME) $(DOCKER_REGISTRY)$(BINARY_NAME):$(VERSION)
	docker push $(DOCKER_REGISTRY)$(BINARY_NAME):latest
	docker push $(DOCKER_REGISTRY)$(BINARY_NAME):$(VERSION)
