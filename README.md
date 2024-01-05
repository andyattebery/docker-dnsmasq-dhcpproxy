# docker-dnsmasq-proxydhcp

This creates a container running dnsmasq with a proxy DHCP server which is used for PXE.

## Environment Variables

##### `DNSMASQ_PROXY_DHCP_SUBNET`
###### _Required:_ Yes
###### _Example:_ 192.168.1.0
DHCP subnet the proxy DHCP server will listen on. 

##### `NETBOOTXYZ_SERVER_IP`
###### _Required:_ No
###### _Example:_ 192.168.1.111
If set, configure for [netboot.xyz](https://netboot.xyz) running on IP.

## Volumes
`/etc/dnsmasq.d` is exposed if other dnsmasq configuration is needed.


## References

### dnsmasq proxy DHCP
- https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html
- https://wiki.archlinux.org/title/Dnsmasq#Proxy_DHCP
- https://wiki.fogproject.org/wiki/index.php?title=ProxyDHCP_with_dnsmasq
- https://manski.net/2016/09/pxe-server-on-existing-network-dhcp-proxy-on-ubuntu/

### PXE Booting
- https://technotim.live/posts/netbootxyz-tutorial/#dhcp-configuration
- https://docs.linuxserver.io/images/docker-netbootxyz/?h=netboo#router-setup-examples
- https://blog.mei-home.net/posts/rpi-netboot/netboot-server/
- https://www.reddit.com/r/raspberry_pi/comments/l7bzq8/guide_pxe_booting_to_a_raspberry_pi_4/

### netboot.xyz
- https://netboot.xyz/docs/docker#netbootxyz-boot-file-types)
