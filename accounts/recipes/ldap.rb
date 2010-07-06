
#
# Configuration
#

LDAP_CONFDIR = "/etc"
LDAP_CONFFILE = LDAP_CONFDIR + "/ldap.conf"
  
template "nss-pam-ldap-conf" do
  path LDAP_CONFFILE
  source "nss_pam_ldap.conf.erb"
  mode 0644
  owner "root"
  group "root"
end

case node[:platform]
when 'redhat', 'centos', 'fedora'
  opts = ['--enableldap', '--enableldapauth',
          '--enablecache', '--enablelocauthorize'].join(' ')
  execute "auth-client" do
    command "authconfig #{opts} --update"
    user "root"
    action :nothing
    subscribes :run, resources(:template => "nss-pam-ldap-conf")
    notifies :restart, resources(:service => 'nscd'), :delayed
  end
else
  execute "auth-client" do
    command "auth-client-config -t nss -p lac_ldap"
    user "root"
    action :nothing
    subscribes :run, resources(:template => "nss-pam-ldap-conf")
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
