/ipv6 firewall address-list remove [/ipv6 firewall address-list find list=cfroutes.ipv6]

:local cidrList {
  "2400:cb00::/32"
  "2606:4700::/32"
  "2803:f800::/32"
  "2405:b500::/32"
  "2405:8100::/32"
  "2a06:98c0::/29"
  "2c0f:f248::/32"
}

:foreach cidr in $cidrList do={
  /ipv6 firewall address-list add address=$cidr list=cfroutes.ipv6
}
