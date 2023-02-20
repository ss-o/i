# ⚡ `i-get`

<div align="center"><h2>
  
[![Fly CI](https://github.com/ss-o/i/actions/workflows/fly-action.yml/badge.svg)](https://github.com/ss-o/i/actions/workflows/fly-action.yml)
[![Docker CI](https://github.com/ss-o/i/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/ss-o/i/actions/workflows/docker-publish.yml)
[![Release CI](https://github.com/ss-o/i/actions/workflows/go-release.yml/badge.svg)](https://github.com/ss-o/i/actions/workflows/go-release.yml)

</div></h2>

<div align="center"><h3>
<p>✨ A very lightweight `HTTP` server based on `GO` ✨</p>
<p>✨ It will try to detect your OS and architecture and return as `SHELL` script. ✨</p>

</div></h3>

## 📶 Try it

- Example to check in browser.
  https://i-get.fly.dev/DNSCrypt/dnscrypt-proxy

```bash
bash <(curl -Ss https://i-get.fly.dev/<user>/<repo>@<release>)
```

- 🔭 Example find latest binary

```bash
bash <(curl -Ss https://i-get.fly.dev/coredns)
```

- Specific version

```bash
bash <(curl -Ss https://i-get.fly.dev/coredns/coredns@v1.8.5)
```

## 💡 Options

- Will try to find, if found will download it after 10s

```sh
bash <(curl -sS https://example.com/<user>)
```

- Download the latest release

```sh
bash <(curl -sS https://example.com/<user>/<repo>)
```

- Download the required version and move to '/usr/local/bin'

```sh
bash <(curl -sS https://example.com/<user>/<repo>@<release>\!)
```

- Download the required version and move to '/usr/local/bin' using 'sudo'

```sh
bash <(curl -sS https://example.com/<user>/<repo>@<release>\!\!)
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

---

## Self-Host

### 📥 Go

- Go install

```sh
go install github.com/ss-o/i@latest
```

- 💬 Run to see options

```sh
i --help
```

---

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

> ℹ️ Check [docker-compose.yml](https://github.com/ss-o/i/raw/main/docker-compose.yml)

- 👯 Try

```sh
bash <(curl -Ss http://localhost:3000/<user>/<repo>@<release>)
```

---

### 🐧 Installer

```sh
bash <(curl -Ss https://i-get.fly.dev/ss-o/i\!\!)
```

- 💬 Run to see options

```sh
i --help
```
