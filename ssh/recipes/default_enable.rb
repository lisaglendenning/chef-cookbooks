
#
# Supported Platforms
#

rhels = ['redhat', 'centos', 'fedora']

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

template CONFFILE do
  source "sshd_config.erb"
  mode 0644
  owner "root"
  group "root"
end

service "ssh" do
  case node[:platform]
  when rhels
    service_name "sshd"
  else
    service_name "ssh"
  end
  supports :restart => true
  action [:enable, :start]
  subscribes :restart, resources(:template => CONFFILE)
end

if node[:components].key?(:firewall)
  if ! node[:components][:firewall][:registry].key?(:ssh)
    node[:components][:firewall][:registry][:ssh] = node[:components][:ssh][:server][:transports]
  end
end
