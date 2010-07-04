
props = node[:components][:ldap_client]
  
props.each { |k,v|
  Chef::Log.info(k.to_s)
  Chef::Log.info(v.to_s)
}

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
