
node.default[:components][:firewall][:defaults] = <<HERE
#
# Default policies
#
 iptables -P INPUT DROP
 iptables -P OUTPUT ACCEPT
 iptables -P FORWARD DROP
  
#
# Access for localhost
#
 iptables -A INPUT -i lo -j ACCEPT
  
#
# Accept packets belonging to established and related connections
#
 iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  
#
# DHCP Client
#
 iptables -A INPUT -p udp --dport 68 -j ACCEPT 
  
#
# Ping
#
 iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
HERE
