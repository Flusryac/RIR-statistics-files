#!/bin/bash

GetSources() {
    wget -O $sources/chn.txt https://raw.githubusercontent.com/Loyalsoldier/geoip/refs/heads/release/text/cn.txt
    wget -O $sources/cf4.txt https://www.cloudflare.com/ips-v4
    wget -O $sources/cf6.txt https://www.cloudflare.com/ips-v6
}

ConvertToROSchnv4() {
    grep '\.' $sources/chn.txt > $tmp/chnroutes.rsc.tmp
    cat << EOF > $tmp/chnroutes.rsc
/ip firewall address-list remove [/ip firewall address-list find list=chnroutes]
/ip firewall address-list
add address=0.0.0.0/8 list=chnroutes comment=private-network
add address=10.0.0.0/8 list=chnroutes comment=private-network
add address=100.64.0.0/10 list=chnroutes comment=private-network
add address=127.0.0.0/8 list=chnroutes comment=private-network
add address=169.254.0.0/16 list=chnroutes comment=private-network
add address=172.16.0.0/12 list=chnroutes comment=private-network
add address=192.0.0.0/24 list=chnroutes comment=private-network
add address=192.0.2.0/24 list=chnroutes comment=private-network
add address=192.88.99.0/24 list=chnroutes comment=private-network
add address=192.168.0.0/16 list=chnroutes comment=private-network
add address=198.51.100.0/24 list=chnroutes comment=private-network
add address=203.0.113.0/24 list=chnroutes comment=private-network
add address=224.0.0.0/3 list=chnroutes comment=private-network
add address=233.252.0.0/24 list=chnroutes comment=private-network
add address=240.0.0.0/4 list=chnroutes comment=private-network
add address=255.255.255.255/32 list=chnroutes comment=private-network

:local cidrList {
EOF
    sed -e 's/^/  "&/g' -e 's/$/&"/g' $tmp/chnroutes.rsc.tmp >> $tmp/chnroutes.rsc
    cat << EOF >> $tmp/chnroutes.rsc
}

:foreach cidr in /$cidrList do={
  /ip firewall address-list add address=/$cidr list=chnroutes
}
EOF
    mv $tmp/chnroutes.rsc $release
}

ConvertToROSchnv6() {
    grep ':' $sources/chn.txt > $tmp/chnroutes.ipv6.rsc.tmp
    cat << EOF > $tmp/chnroutes.ipv6.rsc
/ipv6 firewall address-list remove [/ipv6 firewall address-list find list=chnroutes.ipv6]
/ipv6 firewall address-list
add address=::/128 list=chnroutes.ipv6 comment=private-network
add address=::1/128 list=chnroutes.ipv6 comment=private-network
add address=::ffff:0:0/96 list=chnroutes.ipv6 comment=private-network
add address=::ffff:0:0:0/96 list=chnroutes.ipv6 comment=private-network
add address=64:ff9b::/96 list=chnroutes.ipv6 comment=private-network
add address=64:ff9b:1::/48 list=chnroutes.ipv6 comment=private-network
add address=100::/64 list=chnroutes.ipv6 comment=private-network
add address=2001::/32 list=chnroutes.ipv6 comment=private-network
add address=2001:20::/28 list=chnroutes.ipv6 comment=private-network
add address=2001:db8::/32 list=chnroutes.ipv6 comment=private-network
add address=2002::/16 list=chnroutes.ipv6 comment=private-network
add address=3fff::/20 list=chnroutes.ipv6 comment=private-network
add address=5f00::/16 list=chnroutes.ipv6 comment=private-network
add address=fc00::/7 list=chnroutes.ipv6 comment=private-network
add address=fe80::/10 list=chnroutes.ipv6 comment=private-network
add address=ff00::/8 list=chnroutes.ipv6 comment=private-network

:local cidrList {
EOF
    sed -e 's/^/  "&/g' -e 's/$/&"/g' $tmp/chnroutes.ipv6.rsc.tmp >> $tmp/chnroutes.ipv6.rsc
    cat << EOF >> $tmp/chnroutes.ipv6.rsc
}

:foreach cidr in /$cidrList do={
  /ipv6 firewall address-list add address=/$cidr list=chnroutes.ipv6
}
EOF
    mv $tmp/chnroutes.ipv6.rsc $release
}

ConvertToROScfv4() {
    grep '\.' $sources/cf4.txt > $tmp/cfroutes.rsc.tmp
    cat << EOF > $tmp/cfroutes.rsc
/ip firewall address-list remove [/ip firewall address-list find list=cfroutes]

:local cidrList {
EOF
    sed -e 's/^/  "&/g' -e 's/$/&"/g' $tmp/cfroutes.rsc.tmp >> $tmp/cfroutes.rsc
    cat << EOF >> $tmp/cfroutes.rsc
}

:foreach cidr in /$cidrList do={
  /ip firewall address-list add address=/$cidr list=cfroutes
}
EOF
    mv $tmp/cfroutes.rsc $release
}

ConvertToROScfv6() {
    grep ':' $sources/cf6.txt > $tmp/cfroutes.ipv6.rsc.tmp
    cat << EOF > $tmp/cfroutes.ipv6.rsc
/ipv6 firewall address-list remove [/ipv6 firewall address-list find list=cfroutes.ipv6]

:local cidrList {
EOF
    sed -e 's/^/  "&/g' -e 's/$/&"/g' $tmp/cfroutes.ipv6.rsc.tmp >> $tmp/cfroutes.ipv6.rsc
    cat << EOF >> $tmp/cfroutes.ipv6.rsc
}

:foreach cidr in /$cidrList do={
  /ipv6 firewall address-list add address=/$cidr list=cfroutes.ipv6
}
EOF
    mv $tmp/cfroutes.ipv6.rsc $release
}

main() {
    mkdir ./tmp
    mkdir ./tmp/sources
    mkdir ./tmp/tmp

    sources=./tmp/sources
    tmp=./tmp/tmp
    release=./release

    GetSources
    ConvertToROSchnv4
    ConvertToROSchnv6
    ConvertToROScfv4
    ConvertToROScfv6

    rm -r ./tmp
}

main