export PATH := $(GOPATH)/bin:$(PATH)

all: fmt build

build: frps frpc

# compile assets into binary file
file:
	rm -rf ./assets/static/*
	cp -rf ./web/frps/dist/* ./assets/static
	go get -d github.com/rakyll/statik
	go install github.com/rakyll/statik
	rm -rf ./assets/statik
	go generate ./assets/...

fmt:
	go fmt ./...

frps:
	go build -o bin/frps ./cmd/frps
	@cp -rf ./assets/static ./bin

frpc:
	go build -o bin/frpc ./cmd/frpc

test: gotest

gotest:
	go test -v ./assets/...
	go test -v ./client/...
	go test -v ./cmd/...
	go test -v ./models/...
	go test -v ./server/...
	go test -v ./utils/...

ci:
	cd ./tests && ./run_test.sh && cd -
	go test -v ./tests/...
	cd ./tests && ./clean_test.sh && cd -

cic:
	cd ./tests && ./clean_test.sh && cd -

alltest: gotest ci

clean:
	rm -fr ./bin/darwin_amd64
	rm -fr ./bin/linux_amd64
	rm -fr ./bin/linux_arm64
	rm -f ./bin/frpc
	rm -f ./bin/frps
	cd ./tests && ./clean_test.sh && cd -
