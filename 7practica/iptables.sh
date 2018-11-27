#!/bin/sh

IPT=/sbin/iptables

#Blank state
./resetfw.sh


#Aceptar todo para output, denegar todo para input y forward
$IPT -P OUTPUT ACCEPT
$IPT -P INPUT DROP
$IPT -P FORWARD DROP 

#Internet para los usuarios de la red interna
# DUDA: COMO DAR INTERNET CUANDO SE ACTIVA EL FORWARDING 80->8080
# RESPUESTA: ES EL SIGUIENTE PASO 
$IPT -A FORWARD -i ens3 -o ens6 -j ACCEPT
$IPT -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT


$IPT -t nat -P OUTPUT ACCEPT
$IPT -t nat -P PREROUTING ACCEPT
$IPT -t nat -P POSTROUTING ACCEPT
$IPT -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
# Poner ip de ens6 a los paquetes que salen a internet
$IPT -t nat -A POSTROUTING -o ens6 -j MASQUERADE

$IPT -N SERVICES

#Permitir trafico en loopback
$IPT -A INPUT --in-interface lo -j ACCEPT
#Permitir respuesta de conexiones establecidas
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#Para permitir pings
$IPT -A INPUT -p icmp -j ACCEPT
#Cadena para gestionar los servicios
$IPT -A INPUT -j SERVICES
#Aceptar conexiónes desde la red interna a los puertos 80 (web) y 22
       #	(servicio SSH en el FW)
#ssh
$IPT -A SERVICES --in-interface ens3 -p tcp --dport 22 -j ACCEPT
#para conectarme yo por ssh
$IPT -A SERVICES --in-interface ens6 -p tcp --dport 22 -j ACCEPT
#servidor web
# COMO SE HACE FORWARDING DE 80 a 8080 hay que permitir en los dos !!!
$IPT -A SERVICES --in-interface ens3 -p tcp --dport 80 -j ACCEPT
$IPT -A SERVICES --in-interface ens3 -p tcp --dport 8080 -j ACCEPT
#impresora
$IPT -A SERVICES -m iprange --src-range 192.168.2.1-192.168.2.254 \
	-p tcp --dport 631 -j ACCEPT

