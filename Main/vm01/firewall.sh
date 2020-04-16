#!/bin/bash

sysctl="/sbin/sysctl -w"
iptables="/sbin/iptables"
publicaddr="10.0.2.1"
privateaddr="192.168.33.11"
any="0.0.0.0/0"
localnet="192.168.33.0/24"

if [ "$sysctl" = "" ]
then
    echo "1" > /proc/sys/net/ipv4/ip_forward
else
    $sysctl net.ipv4.ip_forward="1"
fi


#Flush the existing rules
$iptables -F INPUT
$iptables -F OUTPUT
$iptables -F FORWARD
$iptables -F -t nat

#Now defining the standard policy
$iptables -P INPUT DROP
$iptables -P OUTPUT ACCEPT
$iptables -P FORWARD ACCEPT

# Allow access to the firewall from the localnet
$iptables -A INPUT -s $localnet -d $privateaddr -j ACCEPT

# Allow access to the firewall from the vm02
$iptables -A INPUT -s 192.168.33.12 -d $publicaddr -j ACCEPT

# Allow access from ourself to us !
$iptables -A INPUT -i lo -j ACCEPT

# Allow the firewall box to access the internet
$iptables -A INPUT -s $any -d $publicaddr -m state --state ESTABLISHED,RELATED -j ACCEPT

# Should we masquerade vm02 to internet
$iptables -t nat -A POSTROUTING -s 192.168.33.12 -d $any -j MASQUERADE
