
package "iptables" do
  action :upgrade
end

#
# Iptables script
#

BINDIR = '/usr/sbin'
BINFILE = BINDIR + '/iptables.sh'

template BINFILE do
  source "iptables.sh.erb"
  mode 0755
  owner "root"
  group "root"
  variables(
    :defaults => node[:components][:firewall][:defaults],
    :services => node[:components][:firewall][:services])
end

execute "rebuild-iptables" do
  command BINFILE
  action :nothing
  subscribes :run, resources(:template => BINFILE)
end
