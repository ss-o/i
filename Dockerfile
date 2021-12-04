FROM golang:1.17.4-alpine

RUN apk add --no-cache \
ca-certificates=~20191127 \
openssl=~1.1.1 \
make=~4.3 \
git=~2.32 \
wget=~1.21 \
curl=~7.79 \
&& rm -rf /var/cache/apk/*

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
