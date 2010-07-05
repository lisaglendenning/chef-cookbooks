
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

service 'ssh' do
  case node[:platform]
  when 'redhat', 'centos', 'fedora'
    service_name "sshd"
  else
    service_name "ssh"
  end
  supports :restart => true, :status =>true
  action [:enable, :start]
end

template 'sshd-conf' do
  path CONFFILE
  source "sshd_config.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => 'ssh')
end

if node[:components].key?(:firewall)
  if ! node[:components][:firewall][:registry].key?(:ssh)
    node[:components][:firewall][:registry][:ssh] = node[:components][:ssh][:server][:transports]
  end
end
