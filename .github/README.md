# 🧰 `i`

<div align="center">

  <img src="https://g-assets.ss-o.workers.dev/img/digital-clouds/png/w600/600x600.png" width="300" height="300">
  
[![Docker CI](https://github.com/ss-o/i/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/ss-o/i/actions/workflows/docker-publish.yml)
[![Release CI](https://github.com/ss-o/i/actions/workflows/release.yml/badge.svg)](https://github.com/ss-o/i/actions/workflows/release.yml)
</div>

---

<div align="center">
Lightweight 'HTTP Server' based on 'Go', will try detect OS and architecture to return as 'Shell' script. Accessing from the browser will allow choosing from a selection of URLs, which also can be accessed in the terminal with additional optionality.
</div>
  
## 📶 Try it

- Example to check in browser. 
https://get.digitalclouds.one/DNSCrypt/dnscrypt-proxy

```sh
curl https://get.digitalclouds.one/<user>/<repo>@<release> | bash
# Example find latest binary
curl https://get.digitalclouds.one/coredns | bash
# Specific version
curl https://get.digitalclouds.one/coredns/coredns@v1.8.0 | bash
# Latest binary to PATH with sudo
curl https://get.digitalclouds.one/coredns/coredns\!\! | bash
```

### 💡 Options

- Will try to find, if found will download after 10s
```sh
curl https://example.com/<user> | bash
````

- Download latest release
```sh
curl https://example.com/<user>/<repo> | bash
```

- Download required version and move to '/usr/local/bin'
```sh
curl https://example.com/<user>/<repo>@<release>\! | bash
```

- Download required version and move to '/usr/local/bin' using 'sudo'
```sh
curl https://example.com/<user>/<repo>@<release>\!\! | bash
```


```sh
# Environment variables
PORT      ||  Set listen port
USER      ||  Set default user
GH_TOKEN  ||  Set GitHub API 

# Usage options
  --port,    -p     Port (default 3000)
  --user,    -u     User (default ss-o)
  --token,   -t     GitHub API Token
  --version, -v     Version
  --help,    -h     Display Help
```
> [authenticating-with-the-api](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-authentication-to-github#authenticating-with-the-api)

## Self-Host

### 📥 Go

```sh
# Go install
go install github.com/ss-o/i@latest
# Run to see options
i --help
```

```sh
# Build
git clone https://github.com/ss-o/i && \
cd i && \
make vendor && \
make build && \
./bin/i
```


### 🐳 Docker

```sh
docker run -it --rm -p 3000:3000 ghcr.io/ss-o/i:latest \
--token yourgithubtoken --user yourusername
```

```sh
# Run detached
docker run -d -p 3000:3000 --restart always --name i-get ghcr.io/ss-o/i:latest \
--token yourgithubtoken --user yourusername
```

```sh
# From Git
git clone https://github.com/ss-o/i && \
cd i && \
docker-compose up
```
> Check [docker-compose.yml](https://github.com/ss-o/i/raw/main/docker-compose.yml)

```sh
# Try
curl http://localhost:3000/<user>/<repo>@<release> | bash
```

### 🐧 Installer

```sh
curl https://get.digitalclouds.one/ss-o/i\!\! | bash
# Run to see options
i --help
```

### 🧰 Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/ss-o/i)

