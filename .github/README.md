# 🧰 `i`

<div align="center">

  <img src="https://github.githubassets.com/images/modules/site/social-cards/git-guides/install-git.png" width="600" height="300">
  
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
go install github.com/ss-o/i@latest
# Run to see options
i --help
```

### 🐳 Docker

```sh
docker run -d -p 3000:3000 --restart always --name get-it ghcr.io/ss-o/i:latest
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

