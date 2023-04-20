SHELL:=/bin/bash
BUILD_DIR:=dist
BINARY_NAME:=i
SERVICE_PORT:=3000
GO111MODULE:=on
CGO_ENABLED:=0

build:
	@echo "Building..."
	@go build -buildvcs=false -o $(BINARY_NAME) .
	@echo "Build complete!"

test: build
	@echo "Running tests..."
	@go test -v ./handler

# Go
clean:
	$(shell rm -rf $(BUILD_DIR) && go clean)
	@echo "Clean complete!"

## Docker
docker-build:
	@echo "Building docker image..."
	@docker build --rm --tag $(BINARY_NAME) .

docker-watch: docker-build
	@echo "Running docker image..."
	$(eval PACKAGE_NAME=$(shell head -n 1 go.mod | cut -d ' ' -f2))
	@docker run -it --rm -w /go/src/$(PACKAGE_NAME) -v $(shell pwd):/go/src/$(PACKAGE_NAME) -p $(SERVICE_PORT):$(SERVICE_PORT) $(BINARY_NAME)

docker-detached-run: docker-build
	@docker run -d -p $(SERVICE_PORT):$(SERVICE_PORT) --restart always $(BINARY_NAME)

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.PHONY: build test clean docker-build docker-watch
