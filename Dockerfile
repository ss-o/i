FROM golang:1.20.3-alpine

RUN apk update \
  && apk add --no-cache \
  ca-certificates \
  openssl \
  make \
  git \
  && rm -rf /var/cache/apk/*

WORKDIR /bin

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
