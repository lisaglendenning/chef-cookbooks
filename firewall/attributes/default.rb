
default[:components][:firewall][:defaults] = <<HERE
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

default[:components][:firewall][:registry] = Mash.new

services = ""
components[:firewall][:registry].each { |name,rules|
  text = "#\n# #{name}\n#\n "
  services << text
  rules.each { |rule|
    text = "iptables -A INPUT -j ACCEPT"
    rule.each { |k,v|
      case k
      when :protocol
        text << " -p #{v}"
      when :port
        text << " --dport #{v}"
      end
    }
    services << text << "\n"
  }
}
set[:components][:firewall][:services] = services
