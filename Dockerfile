FROM golang:1.27.1-alpine@sha256:8a5910f31396cd4d89662f56c68b3ae31d374308270a1c3bd96672ee5ed43414 AS builder

COPY . /src
WORKDIR /src

RUN set -ex \
 && apk --no-cache add \
      bash \
      curl \
      git \
      make \
 && bash /src/gotools.sh \
 && rootzone >named.stubs \
 && make blacklist

# ------

FROM alpine:3.24.2@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

LABEL org.opencontainers.image.title="personal-dns" \
      org.opencontainers.image.description="personal-dns is a Bind9 DNS server in a container with privacy and adblock enabled" \
      org.opencontainers.image.authors="Knut Ahlers <knut@ahlers.me>" \
      org.opencontainers.image.url="https://git.luzifer.io/luzifer-docker/personal-dns" \
      org.opencontainers.image.documentation="https://git.luzifer.io/luzifer-docker/personal-dns" \
      org.opencontainers.image.source="https://git.luzifer.io/luzifer-docker/personal-dns" \
      org.opencontainers.image.licenses="Apache-2.0"

RUN set -ex \
 && apk --no-cache add \
      bash \
      bind \
      bind-tools \
      dumb-init

COPY --from=builder /go/bin/bind-log-metrics  /usr/local/bin/
COPY --from=builder /src/named.stubs          /etc/bind/
COPY --from=builder /src/named.blacklist      /etc/bind/
COPY                named.conf                /etc/bind/
COPY                docker-entrypoint.sh      /usr/local/bin/

EXPOSE 53/udp 53

HEALTHCHECK --interval=30s --timeout=5s --start-period=2m \
  CMD dig +short @localhost health.pdns.luzifer.io A || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
