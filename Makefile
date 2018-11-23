export PATH := $(GOPATH)/bin:$(PATH)
LDFLAGS := -s -w

all: build

build: app

app:
	env CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o ./bin/darwin_amd64/frpc ./cmd/frpc
	env CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o ./bin/darwin_amd64/frps ./cmd/frps
	env CGO_ENABLED=0 GOOS=linux  GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o ./bin/linux_amd64/frpc ./cmd/frpc
	env CGO_ENABLED=0 GOOS=linux  GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o ./bin/linux_amd64/frps ./cmd/frps
	env CGO_ENABLED=0 GOOS=linux  GOARCH=arm64 go build -ldflags "$(LDFLAGS)" -o ./bin/linux_arm64/frpc ./cmd/frpc

temp:
	env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o ./frps_linux_amd64 ./cmd/frps

# compile assets into binary file
file:
	rm -rf ./assets/static/*
	cp -rf ./web/frps/dist/* ./assets/static
	go get -d github.com/rakyll/statik
	go install github.com/rakyll/statik
	rm -rf ./assets/statik
	go generate ./assets/...

clean:
	rm -fr ./bin/darwin_amd64
	rm -fr ./bin/linux_amd64
	rm -fr ./bin/linux_arm64
	rm -f ./bin/frpc
	rm -f ./bin/frps
	cd ./tests && ./clean_test.sh && cd -
