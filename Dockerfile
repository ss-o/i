FROM golang:1.20.3-alpine AS builder

ARG GO111MODULE CGO_ENABLED
ARG USER REPO
ARG HTTP_HOST PORT
ARG FORCE_USER FORCE_REPO
ARG GITHUB_TOKEN

# trunk-ignore(hadolint/DL3018)
RUN apk add --no-cache --virtual .build-deps \
    git \
    make \
    bash \
    ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/cache/apk/*

WORKDIR /app

COPY . .

RUN make build && apk del .build-deps

FROM alpine:3.17.3

COPY --from=builder /app/dist/i_linux_amd64_v1/i /usr/local/bin/

EXPOSE 3000

HEALTHCHECK --interval=5m --timeout=3s --retries=3 \
CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/usr/local/bin/i"]
