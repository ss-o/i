FROM golang:1.17.1-alpine

LABEL maintainer="Salvydas Lukosius <sall@digitalclouds.dev>"
LABEL org.opencontainers.image.source = "https://github.com/ss-o/i"

RUN apk add --update
RUN apk add --no-cache build-base ca-certificates openssl make git

WORKDIR /app

COPY . .
RUN go get -d -v ./...
RUN go install -v ./...
RUN go mod download
RUN make build

EXPOSE 3000

ENTRYPOINT ["./bin/i"]
CMD ["--token", "$GH_TOKEN"]
