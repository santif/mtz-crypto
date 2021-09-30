SVC_NAME := $(shell grep 'const ServiceName' pkg/version.go | cut -f2 -d '"')
APP_VSN := $(shell grep 'const Version' pkg/version.go | cut -f2 -d '"')
BUILD := $(shell git rev-parse --short HEAD)
IMAGE_NAME = mtzio/${SVC_NAME}

.PHONY: build
build:
	go build -o mtz-crypto-service ./cmd/...

.PHONY: build-race
build-race:
	go build -race -o mtz-crypto-service ./cmd/...

.PHONY: generate-mocks
generate-mocks:
	mockery --all

.PHONY: test
test: build
	go test -covermode=atomic -race -v -count=1 -coverprofile=coverage.out ./pkg/...
	go tool cover -func coverage.out | grep total

.PHONY: docker-build
docker-build:
	docker build \
		-t $(IMAGE_NAME):$(APP_VSN)-$(BUILD) \
		-t $(IMAGE_NAME):latest \
		.

.PHONY: docker-push
docker-push:
	docker push $(IMAGE_NAME):$(APP_VSN)-$(BUILD)
	docker push $(IMAGE_NAME):latest

.PHONY: load-test
load-test:
	h2load --h1 -c 50 -t 4 -D 10 --warm-up-time=2s -i test-urls.txt -B 'http://localhost:8000'

.PHONY: lint
lint:
	golangci-lint run