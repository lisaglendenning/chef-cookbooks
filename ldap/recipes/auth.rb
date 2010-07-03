
include_recipe "ldap::client"

#
# Supported Platforms
#

rhels = ['redhat', 'centos', 'fedora']

#
# Packages
#

packages = case node[:platform]
  when rhels
    ['nscd', 'libnss-ldap', 'libpam-ldap']
  else
    ['nscd', 'auth-client-config', 'libnss-ldap', 'libpam-ldap', 
     'ldap-auth-config', 'ldapscripts', 'autodir']
  end
packages.each { |p|
  package p do
   action :upgrade
  end
}

#
# Platform-specific paths
#

NSCD = '/usr/sbin/nscd'

NSS_CONFDIR = "/etc"
NSS_CONFFILE = NSS_CONFDIR + "/ldap.conf"

AUTODIR_CONFDIR = "/etc/default"
AUTODIR_CONFFILE = AUTODIR_CONFDIR + "/autodir"


#
# Configuration
#

if ! node[:ldap][:auth][:uri]
  node[:ldap][:auth][:uri] = node[:ldap][:protocol] + node[:ldap][:domain]
end

if ! node[:ldap][:auth][:basedn]
  node[:ldap][:auth][:basedn] = node[:ldap][:basedn]
end

if ! node[:ldap][:auth][:ssl]
  node[:ldap][:auth][:ssl] = 'start_tls'
end

template NSS_CONFFILE do
  source "nss_pam_ldap.conf.erb"
  mode 0644
  owner "root"
  group "root"
end

autodir_autohome = '"yes"'
if node[:ldap][:auth][:autohome]
  autodir_autohome = node[:ldap][:auth][:autohome]
end
autodir_autogroup = '"no"'
if node[:ldap][:auth][:autogroup]
  autodir_autogroup = node[:ldap][:auth][:autogroup]
end

template AUTODIR_CONFFILE do
  source "autodir.erb"
  mode 0644
  owner "root"
  group "root"
  variables({
    :autohome => autodir_autohome,
    :autogroup => autodir_autogroup
  })
end

managed = ['passwd', 'group', 'hosts']

case node[:platform]
when rhels
  execute "auth-client" do
    command "authconfig"
    user "root"
    action :nothing
    subscribes :run, resources(:template => NSS_CONFFILE)
  end
else
  execute "auth-client" do
    command "auth-client-config -t nss -p lac_ldap"
    user "root"
    action :nothing
    subscribes :run, resources(:template => NSS_CONFFILE)
  end
  execute "pam-auth-update" do
    command "pam-auth-update --package"
    user "root"
    action :nothing
    subscribes :run, resources(:execute => 'auth-client')
    notifies :restart, resources(:service => "ssh"), :delayed
  end
end


#
# Services
#

service "nscd" do
  supports :restart => true, :status => true
  action [:enable, :start]
  subscribes :restart, resources(:execute => 'auth-client')
end

service "autodir" do
  supports :restart => true, :status => false
  action [:enable]
end

# Well, at least on Ubuntu 9.10, the autodir (or autofs?) package is broken
# So we need to make sure autofs4 is loaded
# or something...sigh
case node[:platform]
when rhels
  execute "autofsfix" do
    command ""
    user "root"
    action :nothing
  end
else
  execute "autofsfix" do
    command "depmod && modprobe -r autofs && modprobe autofs4"
    user "root"
    action :nothing
    subscribes :run, resources(:template => AUTODIR_CONFFILE)
    notifies :restart, resources(:service => 'autodir')
  end
end
