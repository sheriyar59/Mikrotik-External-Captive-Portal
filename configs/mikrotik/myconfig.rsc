# 2024-10-26 10:11:38 by RouterOS 7.16.1
# software id = 
#
/interface ethernet
set [ find default-name=ether2 ] name=TO_192.168.2.0 rx-flow-control=auto \
    tx-flow-control=auto
set [ find default-name=ether1 ] disable-running-check=no
/ip hotspot profile
set [ find default=yes ] use-radius=yes
add hotspot-address=192.168.2.1 login-by=cookie,http-pap name=hsprof1 \
    nas-port-type=ethernet radius-accounting=no use-radius=yes
/ip hotspot user profile
set [ find default=yes ] add-mac-cookie=no shared-users=2
/ip pool
add name=dhcp_pool0 ranges=192.168.2.2-192.168.2.254
/ip dhcp-server
add address-pool=dhcp_pool0 interface=TO_192.168.2.0 lease-time=50m name=\
    dhcp1
/ip hotspot
add address-pool=dhcp_pool0 disabled=no interface=TO_192.168.2.0 name=\
    hotspot1 profile=hsprof1
/ip address
add address=192.168.2.1/24 interface=TO_192.168.2.0 network=192.168.2.0
/ip dhcp-client
add interface=ether1
/ip dhcp-server network
add address=192.168.2.0/24 dns-server=8.8.8.8 gateway=192.168.2.1
/ip dns
set servers=8.8.8.8
/ip firewall filter
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
/ip firewall nat
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=masquerade chain=srcnat src-address=192.168.2.0/24
/ip hotspot user
add name=admin
add name=testuser
/ip hotspot walled-garden
add comment="place hotspot rules here" disabled=yes
/ip hotspot walled-garden ip
add action=accept disabled=no dst-address=192.168.18.130 !dst-address-list \
    !dst-port !protocol !src-address !src-address-list
/radius
add address=192.168.18.130 service=hotspot
/radius incoming
set accept=yes
/system note
set show-at-login=no
/user aaa
set accounting=no default-group=write
