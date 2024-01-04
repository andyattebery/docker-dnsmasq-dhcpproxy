#!/bin/sh

# When this option is on, when any command fails (for any of the reasons listed in Consequences of Shell Errors or by returning an exit status greater than zero), the shell immediately shall exit, as if by executing the exit special built-in utility with no arguments
set -e

# When the shell tries to expand an unset parameter other than the '@' and '*' special parameters, it shall write a message to standard error and the expansion shall fail with the consequences specified in Consequences of Shell Errors.
set -u

DNSMASQ_CONF_DIR="/etc/dnsmasq.d"

# print_error() { printf "%s\n" "$*" >&2; }

cat << EOF > "/etc/dnsmasq.conf"
# Ref: https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html

# -p, --port=<port>
# Listen on <port> instead of the standard DNS port (53). Setting this to zero completely disables DNS function, leaving only DHCP and/or TFTP.
port=0

# -8, --log-facility=<facility>
# Set the facility to which dnsmasq will send syslog entries, this defaults to DAEMON, and to LOCAL0 when debug mode is in operation. If the facility given contains at least one '/' character, it is taken to be a filename, and dnsmasq logs to the given file, instead of syslog. If the facility is '-' then dnsmasq logs to stderr. (Errors whilst reading configuration will still go to syslog, but all output from a successful startup, and all output whilst running, will go exclusively to the file.) When logging to a file, dnsmasq will close and reopen the file when it receives SIGUSR2. This allows the log file to be rotated without stopping dnsmasq.
log-facility=-

# --log-dhcp
# Extra logging for DHCP: log all the options sent to DHCP clients and the tags used to determine them.
log-dhcp

# -F, --dhcp-range=[tag:<tag>[,tag:<tag>],][set:<tag>,]<start-addr>[,<end-addr>|<mode>[,<netmask>[,<broadcast>]]][,<lease time>]
# For IPv4, the <mode> may be proxy in which case dnsmasq will provide proxy-DHCP on the specified subnet. (See --pxe-prompt and --pxe-service for details.)
dhcp-range=$DNSMASQ_PROXY_SUBNET,proxy

# -7, --conf-dir=<directory>[,<file-extension>......],
# Read all the files in the given directory as configuration files. If extension(s) are given, any files which end in those extensions are skipped. Any files whose names end in ~ or start with . or start and end with # are always skipped. If the extension starts with * then only files which have that extension are loaded. So --conf-dir=/path/to/dir,*.conf loads all files with the suffix .conf in /path/to/dir. This flag may be given on the command line or in a configuration file. If giving it on the command line, be sure to escape * characters. Files are loaded in alphabetical order of filename.
# Include all files in a directory which end in .conf
conf-dir=$DNSMASQ_CONF_DIR/,*.conf
EOF

if [ -n ${NETBOOTXYZ_SERVER_IP:+set_and_not_empty} ]; then

cat <<- EOF > "$DNSMASQ_CONF_DIR/10-netbootxyz.conf"

# -U, --dhcp-vendorclass=set:<tag>,[enterprise:<IANA-enterprise number>,]<vendor-class>
# Map from a vendor-class string to a tag. Most DHCP clients provide a "vendor class" which represents, in some sense, the type of host. This option maps vendor classes to tags, so that DHCP options may be selectively delivered to different classes of hosts. For example --dhcp-vendorclass=set:printers,Hewlett-Packard JetDirect will allow options to be set only for HP printers like so: --dhcp-option=tag:printers,3,192.168.4.4 The vendor-class string is substring matched against the vendor-class supplied by the client, to allow fuzzy matching. The set: prefix is optional but allowed for consistency.
# Note that in IPv6 only, vendorclasses are namespaced with an IANA-allocated enterprise number. This is given with enterprise: keyword and specifies that only vendorclasses matching the specified number should be searched.
# Architecture numbers from: https://www.iana.org/assignments/dhcpv6-parameters/dhcpv6-parameters.xhtml#processor-architecture

# x86 BIOS
dhcp-vendorclass=set:bios,PXEClient:Arch:00000
# x86 UEFI
dhcp-vendorclass=set:uefi_x86,PXEClient:Arch:00006
# x64 UEFI
dhcp-vendorclass=set:uefi_x64,PXEClient:Arch:00007
# EBC
dhcp-vendorclass=set:uefi_x64,PXEClient:Arch:00009
# ARM 32-bit UEFI
dhcp-vendorclass=set:uefi_arm32,PXEClient:Arch:00010
# ARM 64-bit UEFI
dhcp-vendorclass=set:uefi_arm64,PXEClient:Arch:00011

# -M, --dhcp-boot=[tag:<tag>,]<filename>,[<servername>[,<server address>|<tftp_servername>]]
# (IPv4 only) Set BOOTP options to be returned by the DHCP server. Server name and address are optional: if not provided, the name is left empty, and the address set to the address of the machine running dnsmasq. If dnsmasq is providing a TFTP service (see --enable-tftp ) then only the filename is required here to enable network booting. If the optional tag(s) are given, they must match for this configuration to be sent. Instead of an IP address, the TFTP server address can be given as a domain name which is looked up in /etc/hosts. This name can be associated in /etc/hosts with multiple IP addresses, which are used round-robin. This facility can be used to load balance the tftp load among a set of servers.

dhcp-boot=tag:bios,netboot.xyz.kpxe,netboot.xyz,$NETBOOTXYZ_SERVER_IP
dhcp-boot=tag:uefi_x86,netboot.xyz.efi,netboot.xyz,$NETBOOTXYZ_SERVER_IP
dhcp-boot=tag:uefi_x64,netboot.xyz.efi,netboot.xyz,$NETBOOTXYZ_SERVER_IP
dhcp-boot=tag:uefi_arm32,netboot.xyz-arm64.efi,netboot.xyz,$NETBOOTXYZ_SERVER_IP
dhcp-boot=tag:uefi_arm64,netboot.xyz-arm64.efi,netboot.xyz,$NETBOOTXYZ_SERVER_IP

EOF
fi

exec "$@"