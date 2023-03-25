FROM golang:1.20.2-alpine AS builder

ARG GO111MODULE=on
ARG CGO_ENABLED=0

# trunk-ignore(hadolint/DL3018)
RUN apk add --no-cache --virtual .build-deps \
    make \
    bash \
    ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/cache/apk/*

WORKDIR /app

COPY . .

RUN make build && apk del .build-deps

FROM alpine:3.17.2

COPY --from=builder /app/bin/ /usr/local/bin/

EXPOSE 3000

HEALTHCHECK --interval=1m --timeout=3s --retries=3 \
CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

ENTRYPOINT ["/usr/local/bin/i"]
