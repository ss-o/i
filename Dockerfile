FROM golang:1.17.1-alpine

RUN apk add --update
RUN apk add --no-cache build-base ca-certificates openssl make
WORKDIR /app
COPY . .
RUN go get -d -v ./...
RUN go install -v ./...
RUN go mod download
RUN make build

EXPOSE 3000
ENTRYPOINT ["./bin/i", "--token", "$GH_TOKEN"]