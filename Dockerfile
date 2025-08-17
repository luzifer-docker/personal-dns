FROM golang:1.25-alpine@sha256:f18a072054848d87a8077455f0ac8a25886f2397f88bfdd222d6fafbb5bba440 AS builder

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

FROM alpine:3.22@sha256:4bcff63911fcb4448bd4fdacec207030997caf25e9bea4045fa6c8c44de311d1

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

HEALTHCHECK --interval=30s --timeout=5s \
  CMD dig +short @localhost health.pdns.luzifer.io A || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
