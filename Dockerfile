FROM golang:1.21.13-alpine@sha256:2414035b086e3c42b99654c8b26e6f5b1b1598080d65fd03c7f499552ff4dc94 AS builder

ARG GO111MODULE CGO_ENABLED
ARG USER REPO
ARG HTTP_HOST PORT
ARG FORCE_USER FORCE_REPO
ARG GITHUB_TOKEN

WORKDIR /app

# trunk-ignore(hadolint/DL3018)
RUN apk add --no-cache --virtual .build-deps \
    git \
    make \
    bash \
    ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/cache/apk/*

COPY . .

RUN make build && apk del .build-deps

FROM builder AS production

COPY --from=builder /app/i /usr/local/bin/

EXPOSE 3000

HEALTHCHECK --interval=5m --timeout=3s --retries=3 \
CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/usr/local/bin/i"]
