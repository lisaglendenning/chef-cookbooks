
props = node[:components][:ldap_client]
  
Chef::Log.info(node[:components][:ldap_client].to_s)
Chef::Log.info(node[:components]['ldap_client'].to_s)

#
# Resources
#

props[:packages].each do |p|
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

template CONFFILE do
  source "ldap.conf.erb"
  mode 0644
  owner "root"
  group "root"
  variables(:properties => props)
end
