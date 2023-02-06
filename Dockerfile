FROM golang:1.20.0-alpine

RUN apk update \
  && apk add --no-cache \
  ca-certificates \
  openssl=~1 \
  make=~4 \
  git=~2 \
  && rm -rf /var/cache/apk/*

WORKDIR /app

COPY . .
RUN go get -d -v \
  && go install -v \
  && go mod download \
  && make vendor \
  && make build

EXPOSE 3000

HEALTHCHECK --interval=1m --timeout=3s --retries=3 \
CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

ENTRYPOINT ["i"]
