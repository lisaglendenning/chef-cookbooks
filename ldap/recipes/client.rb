
include_recipe "ldap"

#
# Resources
#

packages = case node[:platform]
  when 'redhat', 'centos', 'fedora'
    ['openldap', 'openldap-clients']
  else
    ['ldap-utils']
  end
  
packages.each do |p|
  package p do
    action :upgrade
  end
end

if node.components.ldap.client.attribute?(:cert)
  certname = node[:components][:ldap][:client][:cert][:key]
  fname = "/tmp/#{certname}.pem"
  ruby_block "install-ssl-#{certname}" do
    block do
      File.open(fname, "r") { |f|
        content = f.readlines().join
        node.set[:components][:ssl][:certregistry][certname][:content] = content
      }
    end
    only_if "[ -f #{fname} ]"
    action node[:components][:ssl][:certregistry][certname][:content] ? :nothing : :create
  end
  remote_file fname do
    path fname
    source node[:components][:ldap][:client][:cert][:source]
    mode "0644"
    owner "root"
    group "root"
    checksum node[:components][:ldap][:client][:cert][:checksum]
    action :create
    notifies :create, resources(:ruby_block => "install-ssl-#{certname}")
  end
  
  node.set[:components][:ldap][:client][:certfile] = node[:components][:ssl][:certregistry][certname][:path] 
end

CONFDIR = case node[:platform]
  when 'redhat', 'centos', 'fedora'
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
  variables(:properties => node[:components][:ldap][:client])
end
