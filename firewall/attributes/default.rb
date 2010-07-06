
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

PARAMETERS = ['protocol']
services = ""
components[:firewall][:registry].each { |name,rules|
  text = "#\n# #{name}\n#\n "
  services << text
  rules.each { |rule|
    text = "iptables -A INPUT -j ACCEPT"
    
    # parameter must be before any extra options
    PARAMETERS.each { |p|
      if rule.key?(p)
        v = rule[p]
        case p.to_s
        when 'protocol'
          text << " -p #{v}"
        end
        break
      end
    }
    rule.each { |k,v|
      key = k.to_s
      if ! PARAMETERS.include?(key)
        case key
        when 'port'
          text << " --dport #{v}"
        when 'ports'
          text << " --dport #{v[0]}:#{v[1]}"
        end
      end
    }
    services << text << "\n"
  }
}
set[:components][:firewall][:services] = services
