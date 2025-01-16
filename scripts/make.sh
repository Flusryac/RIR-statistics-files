#!/bin/bash

GetSources() {
    wget -O $sources/chn.txt https://raw.githubusercontent.com/Loyalsoldier/geoip/refs/heads/release/text/cn.txt
    wget -O $sources/private.txt https://raw.githubusercontent.com/Loyalsoldier/geoip/refs/heads/release/text/private.txt
    wget -O $sources/cf4.txt https://www.cloudflare.com/ips-v4
    wget -O $sources/cf6.txt https://www.cloudflare.com/ips-v6
}

ConvertToROSchnv4() {
    grep '\.' $sources/private.txt > $tmp/chnroutes.rsc.tmp
    grep '\.' $sources/chn.txt >> $tmp/chnroutes.rsc.tmp
    cat << EOF > $tmp/chnroutes.rsc
/ip firewall address-list remove [/ip firewall address-list find list=chnroutes]

:local cidrList {
EOF
    sed -e 's/^/  "&/g' -e 's/$/&"/g' $tmp/chnroutes.rsc.tmp >> $tmp/chnroutes.rsc
    cat << EOF >> $tmp/chnroutes.rsc
}

:foreach cidr in \$cidrList do={
  /ip firewall address-list add address=\$cidr list=chnroutes
}
EOF
    mv $tmp/chnroutes.rsc $release
}

ConvertToROSchnv6() {
    grep ':' $sources/private.txt > $tmp/chnroutes.ipv6.rsc.tmp
    grep ':' $sources/chn.txt >> $tmp/chnroutes.ipv6.rsc.tmp
    cat << EOF > $tmp/chnroutes.ipv6.rsc
/ipv6 firewall address-list remove [/ipv6 firewall address-list find list=chnroutes.ipv6]

:local cidrList {
EOF
    sed -e 's/^/  "&/g' -e 's/$/&"/g' $tmp/chnroutes.ipv6.rsc.tmp >> $tmp/chnroutes.ipv6.rsc
    cat << EOF >> $tmp/chnroutes.ipv6.rsc
}

:foreach cidr in \$cidrList do={
  /ipv6 firewall address-list add address=\$cidr list=chnroutes.ipv6
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

:foreach cidr in \$cidrList do={
  /ip firewall address-list add address=\$cidr list=cfroutes
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

:foreach cidr in \$cidrList do={
  /ipv6 firewall address-list add address=\$cidr list=cfroutes.ipv6
}
EOF
    mv $tmp/cfroutes.ipv6.rsc $release
}

main() {
    mkdir ./tmp
    mkdir ./tmp/sources
    mkdir ./tmp/tmp
    mkdir ./release

    sources=./tmp/sources
    tmp=./tmp/tmp
    release=./release

    GetSources
    ConvertToROSchnv4
    ConvertToROSchnv6
    ConvertToROScfv4
    ConvertToROScfv6

#    rm -r ./tmp
}

main
