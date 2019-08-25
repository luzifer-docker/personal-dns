$TTL 1H

@                         SOA   LOCALHOST. personal-dns.luzifer.io. (1 1h 15m 30d 2h)
                          NS    LOCALHOST.

; Healthcheck record - don't remove
health.pdns.luzifer.io    A     127.0.1.1
version.pdns.luzifer.io   TXT   "{{ .version }} @ {{ now `2006-01-02 15:04:05 -07:00` }}"

; vim: set ft=bindzone:
; Blacklist entries
