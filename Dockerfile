FROM golang:1.17.1-alpine AS build

WORKDIR /app

COPY . .
RUN go mod download
RUN go build -o /installer

FROM gcr.io/distroless/base-debian11

WORKDIR /

COPY --from=build /installer /installer

EXPOSE 3000

USER nonroot:nonroot

ENTRYPOINT ["/installer"]