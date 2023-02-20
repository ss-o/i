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

> 📚 See [more options](https://github.com/ss-o/i/wiki/Docs#-options)

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
