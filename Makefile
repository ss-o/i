SHELL := /bin/sh

GOCMD=go
BINARY_NAME=i
SERVICE_PORT=3000

# Go
clean:
	rm -fr ./bin ./vendor

build:
	mkdir -p ./bin
	GO111MODULE=on $(GOCMD) build -mod vendor -o ./bin/$(BINARY_NAME) .

vendor:
	$(GOCMD) mod vendor

statik:
	cd handler && go generate

## Docker:
docker-watch:
	$(eval PACKAGE_NAME=$(shell head -n 1 go.mod | cut -d ' ' -f2))
	docker run -it --rm -w /go/src/$(PACKAGE_NAME) -v $(shell pwd):/go/src/$(PACKAGE_NAME) -p $(SERVICE_PORT):$(SERVICE_PORT) $(BINARY_NAME)

docker-build:
	docker build --rm --tag $(BINARY_NAME) .

docker-detached-run:
	docker run -d -p $(SERVICE_PORT):$(SERVICE_PORT) --restart always --name get-it $(BINARY_NAME)
