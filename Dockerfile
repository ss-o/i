FROM golang:1.24.4-alpine@sha256:68932fa6d4d4059845c8f40ad7e654e626f3ebd3706eef7846f319293ab5cb7a AS builder

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
