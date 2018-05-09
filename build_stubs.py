#!/usr/bin/env python

import random
import re

import requests
import jinja2
import dns.resolver


BLACKLIST_FILE = 'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts'
IANA_TLD_LIST = 'https://data.iana.org/TLD/tlds-alpha-by-domain.txt'
INTERNIC_ROOT_FILE = 'https://www.internic.net/domain/named.root'
OPENNIC_ROOT = '75.127.96.89'
OPENNIC_FILTER = ["..", "opennic.glue."]
IANA_FILTERS = ['arpa.']

roots = None


def get_generic_ip(fqdn):
    res = dns.resolver.Resolver()
    ans = res.query(fqdn, 'A')

    return ans.rrset.items[0].to_text()


def get_iana_tlds():
    tlds = requests.get(IANA_TLD_LIST).text.split("\n")
    return [t.lower()+'.' for t in tlds if len(t) > 0 and t[0] != "#"]


def get_internic_roots():
    global roots

    if roots is not None:
        return roots

    named_file = requests.get(INTERNIC_ROOT_FILE).text
    roots = []
    for line in named_file.split("\n"):
        match = re.search(r"\s+A\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)$", line)
        if match is None:
            continue
        roots.append(match.group(1))
    return roots


def get_iana_zone_master(zone):
    query = dns.message.make_query(zone, dns.rdatatype.NS)
    ans = dns.query.tcp(query, random.choice(get_internic_roots()))

    glue = {i.name.__str__(): i.items[0].address
            for i in ans.additional
            if i.rdtype == dns.rdatatype.A}

    auth = [i.to_text() for i in ans.authority[0].items]

    return [glue[i] for i in auth if i in glue]


def opennic_ip_from_master(master):
    res = dns.resolver.Resolver()
    res.nameservers = [OPENNIC_ROOT]
    ans = res.query(master, 'A')

    return [i.to_text() for i in ans.rrset.items]


def get_opennic_zone_master(zone):
    res = dns.resolver.Resolver()
    res.nameservers = [OPENNIC_ROOT]
    ans = res.query('{}.opennic.glue.'.format(zone.strip('.')), 'CNAME')

    masters = [t.strip('"')
               for t in ans.rrset.items[0].to_text().split(" ")
               if t.startswith('ns')]
    masters.append('ns0.opennic.glue.')
    master_ips = [opennic_ip_from_master(m) for m in masters]
    return [item for sublist in master_ips for item in sublist]


def get_opennic_tlds():
    res = dns.resolver.Resolver()
    res.nameservers = [OPENNIC_ROOT]
    ans = res.query('tlds.opennic.glue.', 'TXT')

    return [t.strip('"')+'.' for t in ans.rrset.items[0].to_text().split(" ")]


def main():
    entries = {
        "opennic.glue.": [OPENNIC_ROOT],
    }

    iana_tlds = get_iana_tlds()
    if len(iana_tlds) == 0:
        raise Exception("No IANA TLDs found")
    for tld in get_iana_tlds():
        if tld in IANA_FILTERS:
            continue
        print("Working on IANA TLD '{}'...".format(tld))
        entries[tld] = get_iana_zone_master(tld)

    opennic_tlds = get_opennic_tlds()
    if len(opennic_tlds) == 0:
        raise Exception("No OpenNIC TLDs found")
    for tld in get_opennic_tlds():
        if tld in OPENNIC_FILTER:
            continue
        print("Working on OpenNIC TLD '{}'...".format(tld))
        entries[tld] = get_opennic_zone_master(tld)

    with open('named.stubs', 'w') as f:
        f.write(render_corefile(entries))


def render_corefile(entries):
    template = jinja2.Template(open("named.stubs.j2").read())
    return template.render(entries=entries)


if __name__ == '__main__':
    main()
