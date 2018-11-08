#!/bin/sh

IPT = /sbin/iptables

#Blank state
$IPT -F

#Aceptar todo para output, denegar todo para input y forward
$IPT -P OUTPUT ACCEPT
$IPT -P INPUT DROP
$IPT -P FORWARD DROP

$IPT -t nat -P OUTPUT ACCEPT
$IPT -t nat -P PREROUTING ACCEPT
$IPT -t nat -p POSTROUTING

$IPT -N SERVICES

#Permitir trafico en loopback
$IPT -A INPUT --in-interface lo -j ACCEPT

#Cadena para gestionar los servicios
$IPT -A INPUT -j SERVICES
#Aceptar conexiónes desde la red interna a los puertos 80 (web) y 22 (servicio SSH en el FW)
#ssh
$IPT -A SERVICES --in-interface ens3 -p tcp --dport 22 -j ACCEPT
#servidor web
$IPT -A SERVICES --in-interface ens3 -p tcp --dport 80 -j ACCEPT
#impresora 
$IPT -A SERVICES -m iprange --src-range 192.168.2.1-192.168.2.254 -p tcp --dport 631 -j ACCEPT

#Permitir respuesta de conexiones establecidas
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

$IPT -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
$IPT -A FORWARD -p tcp --dport 8080 -j ACCEPT

$IPT -t nat -A POSTROUTING -o ens6 -j MASQUERADE

