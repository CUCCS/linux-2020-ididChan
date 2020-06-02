#!/bin/bash

net_conf="/etc/netplan/01-netcfg.yaml"
initscript="/etc/default/isc-dhcp-server"
card="enp0s9"
address="192.168.57.1/24"
conf_file="/etc/dhcp/dhcpd.conf"
ip_low="192.168.57.10"
ip_high="192.168.57.150"
op_router="192.168.57.200"
op_mask="255.255.255.0"
op_broadcast="192.168.57.255"
def_lstime=86400
mx_lstime=86400