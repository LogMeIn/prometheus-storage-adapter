 # Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
DOCKER=docker
BINARY_NAME=adapter
TARGET=target
BINARY_LINUX=$(TARGET)/$(BINARY_NAME)_linux
BINARY_DARWIN=$(TARGET)/$(BINARY_NAME)_darwin
BINARY_WINDOWS=$(TARGET)/$(BINARY_NAME)_windows.EXE

DOCKER_REPO=wavefronthq
DOCKER_IMAGE=prometheus-storage-adapter
VERSION=0.9.0

all: deps build test
build: 
	$(GOBUILD) -o $(BINARY_NAME) -v
test: 
	$(GOTEST) -v ./...
clean: 
	$(GOCLEAN)
	rm -f $(BINARY_NAME)
	rm -rf $(TARGET)
run:
	$(GOBUILD) -o $(BINARY_NAME) -v ./...
	./$(BINARY_NAME)

dep:
ifeq ($(shell command -v dep 2> /dev/null),)
	go get -u -v github.com/golang/dep/cmd/dep
endif

deps: dep
	dep ensure -v

build-all: deps build-linux build-darwin build-windows
build-docker: build-linux
	$(DOCKER) build -t $(DOCKER_REPO)/$(DOCKER_IMAGE):$(VERSION) .
	$(DOCKER) tag $(DOCKER_REPO)/$(DOCKER_IMAGE):$(VERSION) $(DOCKER_REPO)/$(DOCKER_IMAGE):latest
release: build-all build-docker

# Cross compilation
build-linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) -o $(BINARY_LINUX) -v
build-darwin:
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 $(GOBUILD) -o $(BINARY_DARWIN) -v
build-windows:
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(BINARY_WINDOWS) -v
