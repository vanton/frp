export PATH := $(GOPATH)/bin:$(PATH)

all: fmt build

build: frps frpc

# compile assets into binary file
file:
	rm -rf ./assets/frps/static/*
	rm -rf ./assets/frpc/static/*
	cp -rf ./web/frps/dist/* ./assets/frps/static
	cp -rf ./web/frpc/dist/* ./assets/frpc/static
	rm -rf ./assets/frps/statik
	rm -rf ./assets/frpc/statik
	go generate ./assets/...

fmt:
	go fmt ./...

frps:
	go build -o bin/frps ./cmd/frps

frpc:
	go build -o bin/frpc ./cmd/frpc

app:
	env CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o ./bin/darwin_amd64/frpc ./cmd/frpc
	env CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o ./bin/darwin_amd64/frps ./cmd/frps
	env CGO_ENABLED=0 GOOS=linux  GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o ./bin/linux_amd64/frpc ./cmd/frpc
	env CGO_ENABLED=0 GOOS=linux  GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o ./bin/linux_amd64/frps ./cmd/frps
	env CGO_ENABLED=0 GOOS=linux  GOARCH=arm64 go build -ldflags "$(LDFLAGS)" -o ./bin/linux_arm64/frpc ./cmd/frpc
	# cp -f ./bin/linux_amd64/frpc ~/works/frp/frpc/frpc && cp -f ./bin/linux_amd64/frps ~/works/frp/frps/frps

temp:
	env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o ./frps_linux_amd64 ./cmd/frps

clean:
	rm -fr ./bin/darwin_amd64
	rm -fr ./bin/linux_amd64
	rm -fr ./bin/linux_arm64
	rm -f ./bin/frpc
	rm -f ./bin/frps
