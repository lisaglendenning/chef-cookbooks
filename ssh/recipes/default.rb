
#
# Resources
#

node[:components][:ssh][:packages].each { |p|
  package p do
   action :upgrade
  end
}

CONFDIR = '/etc/ssh'
CONFFILE = CONFDIR + '/sshd_config'

service 'sshd' do
  case node[:platform]
  when 'redhat', 'centos', 'fedora'
    service_name "sshd"
  else
    service_name "ssh"
  end
  supports :restart => true, :status =>true
  action node[:components][:ssh][:server][:enabled] ? [:enable, :start] : [:disable, :stop]
end

template 'sshd-config' do
  path CONFFILE
  source "sshd_config.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => 'sshd')
  variables(
    :server => node[:components][:ssh][:server],
    :platform => node[:platform]
    )
end

if node.components.attribute?(:firewall)
  server = Mash.new(:protocol => 'tcp', :port => node[:components][:ssh][:server][:port])
  node.set[:components][:firewall][:registry][:sshd] = [server]
end

service 'denyhosts' do
  service_name 'denyhosts'
  supports :restart => true, :status =>false
  action [:enable, :start]
end
