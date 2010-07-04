
#
# Supported Platforms
#

rhels = ['redhat', 'centos', 'fedora']

#
# Configuration
#

LDAP_CONFDIR = "/etc"
LDAP_CONFFILE = LDAP_CONFDIR + "/ldap.conf"
  
template LDAP_CONFFILE do
  source "nss_pam_ldap.conf.erb"
  mode 0644
  owner "root"
  group "root"
end

case node[:platform]
when rhels
  execute "auth-client" do
    command "authconfig"
    user "root"
    action :nothing
    subscribes :run, resources(:template => LDAP_CONFFILE)
    notifies :restart, resources(:service => 'nscd'), :delayed
  end
else
  execute "auth-client" do
    command "auth-client-config -t nss -p lac_ldap"
    user "root"
    action :nothing
    subscribes :run, resources(:template => LDAP_CONFFILE)
    notifies :restart, resources(:service => 'nscd'), :delayed
  end
  execute "pam-auth-update" do
    command "pam-auth-update --package"
    user "root"
    action :nothing
    subscribes :run, resources(:execute => 'auth-client')
    notifies :restart, resources(:service => 'ssh'), :delayed
  end
end
