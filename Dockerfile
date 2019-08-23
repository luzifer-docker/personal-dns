FROM golang:alpine as builder

COPY . /src
WORKDIR /src

RUN set -ex \
 && apk --no-cache add \
      bash \
      curl \
      git \
      make \
 && go get -v github.com/Luzifer/rootzone \
 && rootzone >named.stubs \
 && make blacklist

# ------

FROM alpine:latest

ENV DNSMASQ_HOSTSFILE=/etc/bind/blacklist \
    DNSMASQ_POLL=60

LABEL maintainer Knut Ahlers <knut@ahlers.me>

COPY build.sh /usr/local/bin/

RUN set -ex \
 && apk --no-cache add \
      bash \
      bind \
      bind-tools \
 && /usr/local/bin/build.sh

COPY --from=builder /src/named.stubs /etc/bind/
COPY --from=builder /src/blacklist /etc/bind/

COPY named.conf /etc/bind/
COPY Corefile /etc/
COPY docker-entrypoint.sh /usr/local/bin/

EXPOSE 53/udp 53

HEALTHCHECK --interval=30s --timeout=5s \
  CMD dig +short @localhost health.server.test A || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
