# `i-get`

<div align="center">

  <img src="https://g-assets.ss-o.workers.dev/img/digital-clouds/png/w600/600x600.png" width="300" height="300">
  
[![Docker CI](https://github.com/ss-o/i/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/ss-o/i/actions/workflows/docker-publish.yml)
[![Heroku CI](https://github.com/ss-o/i/actions/workflows/heroku-deploy.yml/badge.svg)](https://github.com/ss-o/i/actions/workflows/heroku-deploy.yml)
[![Release CI](https://github.com/ss-o/i/actions/workflows/release.yml/badge.svg)](https://github.com/ss-o/i/actions/workflows/release.yml)
[![DeepSource](https://deepsource.io/gh/ss-o/i.svg/?label=active+issues&show_trend=true&token=KQ8QR8GCSTxHYNoEiG9S1U0L)](https://deepsource.io/gh/ss-o/i/?ref=repository-badge)

</div>

---

<div align="center">
  
A lightweight `HTTP` server based on `GO`, will try to detect your OS and architecture and return as `SHELL` script.
  
</div>

## 📶 Try it

- Example to check in browser. 
https://get.digitalclouds.one/DNSCrypt/dnscrypt-proxy
- Example of this repository.
https://get.digitalclouds.one/i


```sh
curl https://get.digitalclouds.one/<user>/<repo>@<release> | bash
```
- Example find latest binary

```sh
curl https://get.digitalclouds.one/coredns | bash
```
- Specific version

```sh
curl https://get.digitalclouds.one/coredns/coredns@v1.8.0 | bash
```
- Latest binary to PATH with sudo

```sh
curl https://get.digitalclouds.one/coredns/coredns\!\! | bash
```

> 📚 See [more options](https://github.com/ss-o/i/wiki/Docs#-options)

---

## Self-Host

### 📥 Go

- Go install

```sh
go install github.com/ss-o/i@latest
```

- Run to see options

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

- Try

```sh
curl http://localhost:3000/<user>/<repo>@<release> | bash
```

---

### 🐧 Installer

```sh
curl https://get.digitalclouds.one/ss-o/i\!\! | bash
i --help
```

### 🧰 Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/ss-o/i)

