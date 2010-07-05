
rhels = ['redhat', 'centos', 'fedora']

#
# Resources
#

node[:components][:ldap_client][:packages].each do |p|
  package p do
    action :upgrade
  end
end

if node[:components][:ldap_client][:cert]
  certname = node[:components][:ldap_client][:cert][:key]
  ruby_block "install-ssl-#{certname}" do
    block do
      File.open("/tmp/#{certname}", "r") { |f|
        content = f.readlines().join
        if ! node[:components][:ssl][:certregistry].key?(certname) ||
          node[:components][:ssl][:certregistry][certname][:content] != content
          node[:components][:ssl][:certregistry][certname][:content]  = content
        end
      }
    end
    action :nothing
  end
  remote_file "/tmp/#{certname}" do
    source node[:components][:ldap_client][:cert][:source]
    mode "0644"
    owner "root"
    group "root"
    checksum node[:components][:ldap_client][:cert][:checksum]
    action :create
    notifies :create, resources(:ruby_block => "install-ssl-#{certname}")
  end
  
  if node[:components][:ssl][:certregistry][certname][:path]
    node[:components][:ldap_client][:certfile] = node[:components][:ssl][:certregistry][certname][:path]
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
