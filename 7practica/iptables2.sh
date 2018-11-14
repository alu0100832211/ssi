#!/bin/sh

IPT=/sbin/iptables

$IPT -F

# policies

$IPT -P OUTPUT ACCEPT
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -t nat -P OUTPUT ACCEPT
$IPT -t nat -P PREROUTING ACCEPT
$IPT -t nat -P POSTROUTING ACCEPT


$IPT -N SERVICES

# allowed inputs

$IPT -A INPUT --in-interface lo -j ACCEPT
$IPT -A INPUT -j SERVICES

# allow responses
$IPT -A INPUT -m state --state ESTABLISHED, RELATED -j ACCEPT

$IPT -A SERVICES -p tcp --dport 8008 -j ACCEPT
$IPT -A SERVICES -p tcp --dport 22 -j ACCEPT

#Filtrado de ip's para servicio de impresoras
$IPT -A SERVICES -m iprange --src-range 192.168.1.1-192.168.1.254 -p tcp --dport 631 -j ACCEPT
$IPT -A SERVICES -m iprange --src-range 192.168.1.1-192.168.1.254 -p udp --dport 631 -j ACCEPT

$IPT -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
$IPT -A FORWARD -p tcp --dport 8080 -j ACCEPT 
