FROM golang:1.17.1-alpine

LABEL maintainer="Salvydas Lukosius <sall@digitalclouds.dev>"
LABEL org.opencontainers.image.source = "https://github.com/ss-o/i"

RUN apk add --no-cache \
ca-certificates=~20191127-r6 \
openssl=~3.0.0-r2 \
make=~4.3-r0 \
git=~2.33.0-r2 \
wget=~1.21.2-r1

WORKDIR /app

COPY . .
RUN go get -d -v
RUN go install -v
RUN go mod download
RUN make vendor && make build

EXPOSE 3000

HEALTHCHECK --interval=1m --timeout=3s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

ENTRYPOINT ["i"]
