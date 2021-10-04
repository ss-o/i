# `i`

<div align="center">

<img src="https://github.githubassets.com/images/modules/site/social-cards/git-guides/install-git.png" width="600" height="300">

[![Docker CI](https://github.com/ss-o/i/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/ss-o/i/actions/workflows/docker-publish.yml)
[![Release CI](https://github.com/ss-o/i/actions/workflows/release.yml/badge.svg)](https://github.com/ss-o/i/actions/workflows/release.yml)
</div>

## Try it

```sh
curl https://get.digitalclouds.one/<user>/<repo>@<release> | bash
# Example latest binary
curl https://get.digitalclouds.one/coredns | bash
# Specific version
curl https://get.digitalclouds.one/coredns/coredns@v1.8.0 | bash
# Latest binary to PATH with sudo
curl https://get.digitalclouds.one/coredns/coredns\!\! | bash
```

### Options

```sh
# Download release
/<user>/<repo>@<release> | bash

# Download to '/usr/local/bin'
/<user>/<repo>@<release>\! | bash

# Download to '/usr/local/bin' using 'sudo'
/<user>/<repo>@<release>\!\! | bash
```

## Self-Host

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

### Installer

```sh
curl https://get.digitalclouds.one/ss-o/i\!\! | bash
# Run to see options
i --help
```

---

## OS/ARCH Compatibility

> Not accurate. Futher testing required.
- For more details check in browser. 
- Example: https://get.digitalclouds.one/DNSCrypt/dnscrypt-proxy
