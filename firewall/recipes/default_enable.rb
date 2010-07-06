
package "iptables" do
  action :upgrade
end

#
# Iptables script
#

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
    :services => node[:components][:firewall][:services])
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
end
