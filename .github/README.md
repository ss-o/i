# `i`

## Usage

```sh
# Download release
/<user>/<repo>@<release> | bash

# Download to '/usr/local/bin'
/<user>/<repo>@<release>\! | bash

# Download to '/usr/local/bin' using 'sudo'
/<user>/<repo>@<release>\!\! | bash
```

## Try it

```sh
curl https://get.digitalclouds.one/<user>/<repo>@<release> | bash
```

## Install

### Go

```sh
go install github.com/ss-o/i@latest
# Run to see options
i --help
```

### Docker

```sh
docker run -d -p 3000:3000 --restart always --name get-it ghcr.io/ss-o/i:latest
curl http://localhost:3000/<user>/<repo>@<release> | bash
```
