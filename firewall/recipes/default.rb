
packages = ['iptables']
packages.each { |p|
  package p do
    action :upgrade
  end
}

#
# Iptables script
#

PARAMETERS = ['protocol']
services = ""
if node.components.firewall.attribute?(:registry)
  node[:components][:firewall][:registry].each { |name,rules|
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
      services << text << "\n\n"
    }
  }
end

BINDIR = '/usr/sbin'
BINFILE = BINDIR + '/iptables.sh'

execute "rebuild-iptables" do
  command BINFILE
  action :nothing
end

template 'iptables.sh' do
  path BINFILE
  source "iptables.sh.erb"
  mode 0755
  owner "root"
  group "root"
  variables(
    :defaults => node[:components][:firewall][:defaults],
    :services => services
  )
  notifies :run, resources(:execute => 'rebuild-iptables')
end

case node[:platform]
when "redhat", "centos", "fedora"
  service 'iptables' do
    service_name 'iptables'
    supports :restart => true, :status =>true
    action [:enable, :start]
  end
  execute "iptables-save" do
    command "service iptables save"
    action :nothing
    subscribes :run, resources(:execute => 'rebuild-iptables')
  end
else
  iptables_file = '/etc/network/iptables'
  file 'iptables-restore' do
    path "/etc/network/if-pre-up.d/iptables"
    owner "root"
    group "root"
    mode "0754"
    content "#!/bin/sh\niptables-restore < #{iptables_file}\n"
    action :create
  end
  execute 'iptables-save' do
    command "iptables-save > #{iptables_file}"
    action :nothing
    subscribes :run, resources(:execute => 'rebuild-iptables')
  end
end
