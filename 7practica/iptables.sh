#!/bin/sh

#Kernel Support
#Firewall Support
#modprobe x_tables ==> Cargar los modulos
# 1. Averiguar donde esta iptables

IPT = $(whereis iptables)

#blank slate for our firewall so we are not adding rules on top of rules already defined in the kernel
$IPT -F

#default state for policies is accept for output
# outgoing connections allowed
$IPT -P OUTPUT ACCEPT
# incoming connections not accepted
$IPT -P INPUT DROP
#
$IPT -P FORWARD DROP

#new chain
$IPT -t nat -P OUTPUT ACCEPT
$IPT -t nat -P PREROUTING ACCEPT
$IPT -t nat -p POSTROUTING

$IPT -N SERVICES


# allow loopback traffic
# -A = append
# --in-interface lo paquetes recibidos en lo
# -j target of rule
$IPT -A INPUT --in-interface lo -j ACCEPT
$IPT -A INPUT -j SERVICES
#Open specific ports for the internet
#netstat --inet -pln
#web server
# -p tcp protocol
# -dport puerto
#ssh
$IPT -A SERVICES -p tcp --dport 22 -j ACCEPT
$IPT -A SERVICES -p tcp -dport 8008 -j ACCEPT

$IPT -A SERVICES -m iprange --src-range 192.1.68.1-192.168.1.254 -p tcp --dport 631 -j ACCEPT
$IPT -A SERVICES -m iprange --src-range 192.1.68.1-192.168.1.254 -p udp --dport 631 -j ACCEPT

#use google to find default ports
#allow responses from initiated connections
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#NAT TABLE PREROUTING + FORWARD CHAIN


