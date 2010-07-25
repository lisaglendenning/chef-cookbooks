
include_attribute "chef"

if node[:components][:chef][:server][:enabled]
  node.default[:components][:chef][:server][:config] = '/etc/chef/server.rb'
  node.default[:components][:chef][:server][:service_config] = '/etc/sysconfig/chef-server'
  node.default[:components][:chef][:server][:validator] = 'chef-validator'
  node.default[:components][:chef][:server][:validator_key] = '/etc/chef/certificates/validation.pem'
  node.default[:components][:chef][:server][:fqdn] = node[:components][:fqdn] ? node[:components][:fqdn] : node.name 
  node.default[:components][:chef][:server][:port] = 4000
  node.default[:components][:chef][:server][:log_level] = :warn
end

if node[:components][:chef][:webui][:enabled]
  node.default[:components][:chef][:webui][:config] = '/etc/chef/webui.rb'
  node.default[:components][:chef][:webui][:service_config] = '/etc/sysconfig/chef-server-webui'
  node.default[:components][:chef][:webui][:client_user] = 'chef-webui'
  node.default[:components][:chef][:webui][:client_key] = '/etc/chef/webui.pem'
  node.default[:components][:chef][:webui][:fqdn] = "localhost"
  node.default[:components][:chef][:webui][:port] = 4000
  node.default[:components][:chef][:webui][:log_level] = :info
  node.default[:components][:chef][:webui][:admin_user] = 'admin'
  node.default[:components][:chef][:webui][:admin_passwd] = 'p@ssw0rd1'
end
