
rhels = ['redhat', 'centos', 'fedora']

#
# Resources
#

node[:components][:ldap_client][:packages].each do |p|
  package p do
    action :upgrade
  end
end

CONFDIR = case node[:platform]
  when rhels
    "/etc/openldap"
  else
    "/etc/ldap"
  end
CONFFILE = CONFDIR + "/ldap.conf"

template "ldap-client-conf" do
  path CONFFILE
  source "ldap.conf.erb"
  mode 0644
  owner "root"
  group "root"
  variables(:properties => node[:components][:ldap_client])
end
