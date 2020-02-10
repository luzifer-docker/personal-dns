![](https://knut.in/project-status/personal-dns)

# Luzifer / personal-dns

`personal-dns` is a Bind9 DNS server in a container.

The purpose is to be fully independent from provider and third-party DNS servers and have a neat list of additional features:

- No DNS query is sent to your providers DNS servers
- You decide which domains are available to you, no third party company
- On every build a current list of [IANA](https://www.iana.org/domains/root/db) and [OpenNIC](https://wiki.opennic.org/opennic/dot) registered TLDs is loaded together with their authorative nameservers
- The container includes a blacklist generated from the `blacklist-config.yaml` using [named-blacklist](https://github.com/Luzifer/named-blacklist) blocking quite a lot of crap

As soon as you build and roll this DNS container and set your system to use it you should notice a lot of ad- and tracking requests to be gone even for example on your Android device where adblockers does not work that well. Also all connected devices can access any domain registered within the OpenNIC TLDs.

## Usage

### Build and run the container

This is quite easy:

```console
$ docker build -t personal-dns .
$ docker run --rm -ti -p 53:53 -p 53:53/udp personal-dns
$ dig +short @<ip of your container> TXT version.pdns.luzifer.io
"0ecb98c @ 2019-08-25 19:25:14 +00:00"
$ dig +short @<ip of your container> TXT count.pdns.luzifer.io
"128561"
```

### Connect your computer to the container

- On **Mac OS** go into the System Preferences, Network, edit your LAN / WiFi connection, enter the IP your container is reachable into DNS settings
- On **Android** I'm using the [DNS Changer](https://play.google.com/store/apps/details?id=com.frostnerd.dnschanger) App
- On **Android 8+** there is a neat option called "Private DNS" in your "Wi-Fi & Internet" settings
