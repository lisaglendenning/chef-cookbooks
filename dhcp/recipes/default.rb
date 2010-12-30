
require 'ipaddr'

# dhcpd

package "dhcp" do
  action :upgrade
end

service "dhcpd" do
  supports :restart => true, :status => true
  action [:enable, :start]
end

confdir = '/etc'

# All configuration comes from a data bag

dhcp = data_bag_item('network', 'dhcp')

def get_options(bag)
  blocks = []
  if bag.has_key?('options')
    bag['options'].each do |k,v|
      blocks.push({:keyword => :option, :values => [k,v]})
    end
  end
  return blocks
end

def get_parameters(bag)
  blocks = []
  if bag.has_key?('parameters')
    bag['parameters'].each do |k,v|
      blocks.push({:keyword => k, :values => [v]})
    end
  end
  return blocks
end

def get_includes(dir, names)
  blocks = []
  names.each do |name|
    blocks.push({:keyword => :include, :values => ["#{dir}/#{name}.conf"]})
  end
  return blocks
end

# top-level blocks
blocks = get_options(dhcp) + get_parameters(dhcp) + get_includes("#{confdir}/dhcpd.d", ["networks", "clients"])
    
template "dhcpd.conf" do
  path "#{confdir}/dhcpd.conf"
  source "dhcpd.conf.erb"
  mode "0644"
  owner 'root'
  group 'root'
  notifies :restart, resources(:service => "dhcpd")
  variables(:blocks => blocks)
end

confdir = "#{confdir}/dhcpd.d"


#
# Network topology
#

# At the top level are shared physical networks, which can host
# multiple subnets

directory "#{confdir}/networks" do
  mode "0755"
  owner 'root'
  group 'root'
end

blocks = get_includes("#{confdir}/networks", dhcp['networks'].keys)

template "networks.conf" do
  path "#{confdir}/networks.conf"
  source "dhcpd.conf.erb"
  mode "0644"
  owner 'root'
  group 'root'
  variables(:blocks => blocks)
  notifies :restart, resources(:service => "dhcpd")
end

dhcp['networks'].each do |k,v|

  top = {:keyword => 'shared-network',
  :values => [k],
  :blocks => get_options(v) + get_parameters(v) }

  if v.has_key?('pools')
    v['pools'].each do |pool|
      block = {
        :keyword => 'pool', 
        :values => [], 
        :blocks => get_options(pool) + get_parameters(pool)
      }
      top[:blocks].push(block)
    end
  end

  if v.has_key?('subnets')
    v['subnets'].each do |subnet|
      block = {
        :keyword => 'subnet', 
        :values => [subnet['ip'], 'netmask', subnet['mask']], 
        :blocks => get_options(subnet) + get_parameters(subnet)
      }
      top[:blocks].push(block)
    end
  end
  
  template "networks/#{k}.conf" do
    path "#{confdir}/networks/#{k}.conf"
    source "dhcpd.conf.erb"
    mode "0644"
    owner 'root'
    group 'root'
    notifies :restart, resources(:service => "dhcpd")
    variables(:blocks => [top])
  end
end


# Clients, which may correspond to multiple hosts

directory "#{confdir}/clients" do
  mode "0755"
  owner 'root'
  group 'root'
end

blocks = get_includes("#{confdir}/clients", dhcp['hosts'].keys)

template "clients.conf" do
  path "#{confdir}/clients.conf"
  source "dhcpd.conf.erb"
  mode "0644"
  owner 'root'
  group 'root'
  variables(:blocks => blocks)
  notifies :restart, resources(:service => "dhcpd")
end

dhcp['hosts'].each do |k,v|
  
  hosts = []
  if v.key?('interfaces')
    v['interfaces'].each do |name,iface|
      host = {
        :keyword => :host, 
        :values => ["#{k}-#{name}"], 
        :blocks => get_options(iface) + get_parameters(iface)
      }
      host[:blocks].push({:keyword => :hostname, :values => [k]})
      if iface.has_key?('mac')
        host[:blocks].push({:keyword => :hardware, :values => ['ethernet', iface['mac']]})
      end
      if iface.has_key?('assignments')
        iface['assignments'].each do |assign|
          subnet = IPAddr.new(assign['subnet'])
          ip = IPAddr.new(assign['ip']) | subnet
          ihost = Marshal::load(Marshal.dump(host))
          ihost[:values][0] += "-#{subnet}"
          ihost[:blocks].push({:keyword => 'fixed_address', :values => [ip]})
          hosts.push(ihost)
        end
      else
        hosts.push(host)
      end
    end
  end
  
  template "hosts/#{k}.conf" do
    path "#{confdir}/clients/#{k}.conf"
    source "dhcpd.conf.erb"
    mode "0644"
    owner 'root'
    group 'root'
    notifies :restart, resources(:service => "dhcpd")
    variables(:blocks => hosts)
  end
end
