#!/bin/sh

#Comandos para probar el firewall
# Servidor: nc -l -p <puerto> comenzar a escuchar en un puerto
# Cliente: nc <IP> <puerto> escribir en el puerto de esa IP

IPT=/sbin/iptables

$IPT -F

$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP
$IPT -P INPUT DROP

#$IPT -t nat -A POSTROUTING -o ens6 -j MASQUERADE
