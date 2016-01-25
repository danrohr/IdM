#!/bin/bash
cat <<EOF > /etc/krb5.conf
[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 default_realm = LINUX.EXAMPLE.COM
 dns_lookup_realm = false
 dns_lookup_kdc = true
 rdns = false
 ticket_lifetime = 24h
 forwardable = yes
 udp_preference_limit = 0

[realms]
 LINUX.EXAMPLE.COM = {
  kdc =  linux.exmaple.com:88
  master_kdc =  idm01.linux.exmaple.com:88
  admin_server = idm01.linux.example.com:749
  default_domain = linux.example.com
}

[domain_realm]
 .linux.example.com = LINUX.EXAMPLE.COM
 linux.example.com = LINUX.EXAMPLE.COM
EOF
if [ ! -d /root/.ssh/ ]; then
    mkdir -p /root/.ssh/
fi
cd /root/.ssh/
HOSTNAME=$(hostname)
wget --no-check-certificate https://satellite.example.com/pub/id_rsa.pub #<location of the the public key for the user such as a public web share>
ssh -t autoidm@idm01.linux.example.com "./kinituser.sh; ipa host-add $HOSTNAME --password=redhat --force"
/usr/sbin/ipa-client-install --domain=linux.example.com --enable-dns-updates --mkhomedir --password=redhat --realm=LINUX.EXAMPLE.COM --server=idm01.linux.example.com -U -N
