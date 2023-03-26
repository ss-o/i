FROM golang:1.20.2-alpine AS builder

ARG GO111MODULE CGO_ENABLED
ARG USER REPO
ARG HTTP_HOST PORT
ARG FORCE_USER FORCE_REPO
ARG GITHUB_TOKEN

ENV HTTP_HOST=$HTTP_HOST PORT=$PORT
ENV USER=$USER REPO=$REPO
ENV GITHUB_TOKEN=$GITHUB_TOKEN
ENV GO111MODULE=$GO111MODULE CGO_ENABLED=$CGO_ENABLED

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

FROM alpine:3.17.2

COPY --from=builder /app/bin/ /usr/local/bin/

EXPOSE 3000

HEALTHCHECK --interval=5m --timeout=3s --retries=3 \
CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/usr/local/bin/i"]
