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

### 🕸️ See examples in browser

- https://i-get.fly.dev/DNSCrypt/dnscrypt-proxy
- https://i-get.fly.dev/yudai/gotty@v0.0.12
- https://i-get.fly.dev/cloudflared
- https://i-get.fly.dev/mholt/caddy
- https://i-get.fly.dev/rclone

## ✍ Path API

- `user` GitHub user, uses Google to pick most relevant `user` when `repo` not found.
- `repo` GitHub repository belonging to `user` (**required**).
- `release` GitHub release name, defaults to the **latest** release.
- `!` downloads binary directly into `/usr/local/bin/`, otherwise to current directory.

> **Note**: Based on the shell configuration it may require to escape character `!` ➜ `\!` or quote `'https://example.com/request!'` the URL string.

```sh
bash <(curl -sL 'i-get.fly.dev/<user>/<repo>@<release>!')
```

```sh
curl i-get.fly.dev/<user>/<repo>@<release>! | bash
```

```sh
wget -qO- i-get.fly.dev/<user>/<repo>@<release>! | bash
```

## 💡 Query Parameters

- `?type=` force the return type: `script` or `text`
  - `type` is normally detected via `User-Agent` header
- `?insecure=1` force `curl`/`wget` to skip certificate checks
  - client will be prevented to authenticate using the `GITHUB_TOKEN` for security reasons.
- `?as=` rename binary with appended value.

```sh
bash <(curl -sL 'i-get.fly.dev/coredns?type=script')
```

```sh
bash <(curl -sL 'i-get.fly.dev/coredns/coredns?as=dns')
```

```sh
curl i-get.fly.dev/coredns?insecure=1 | bash
```

## Private repositories

Requires `GITHUB_TOKEN` set as environment variable before starting server and running requests on a client.

### Lock user/repository

In some cases, people want an installer server for a single tool

```sh
export FORCE_USER=cloudflare
export FORCE_REPO=cloudflared
./i
```

Then calls to `curl 'localhost:3000` will return the install script for `cloudflare/cloudflared`

- Will try to find, if found will download it after 6s

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
Usage: i [options]

Options:
  --host, -h        host (env HTTP_HOST)
  --port, -p        port (default 3000, env PORT)
  --user, -u        default user for URL requests (default ss-o, env USER)
  --token, -t       token for GitHub API (env GITHUB_TOKEN)
  --force-user, -f  forcefully use single owner (env FORCE_USER)
  --force-repo      forcefully use a single repository (env FORCE_REPO)
  --version, -v     display version
  --help            display help
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
