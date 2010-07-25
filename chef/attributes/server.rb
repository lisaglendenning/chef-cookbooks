
include_attribute "chef"

if node[:components][:chef][:server][:enabled]  
  default[:components][:chef][:server][:config] = '/etc/chef/server.rb'
  default[:components][:chef][:server][:service_config] = '/etc/sysconfig/chef-server'
  default[:components][:chef][:server][:validator] = 'chef-validator'
  default[:components][:chef][:server][:validator_key] = '/etc/chef/certificates/validation.pem'
  default[:components][:chef][:server][:fqdn] = node[:components][:fqdn]
  default[:components][:chef][:server][:port] = 4000
  default[:components][:chef][:server][:log_level] = :warn
end

if node[:components][:chef][:webui][:enabled]
  default[:components][:chef][:webui][:config] = '/etc/chef/webui.rb'
  default[:components][:chef][:webui][:service_config] = '/etc/sysconfig/chef-server-webui'
  default[:components][:chef][:webui][:client_user] = 'chef-webui'
  default[:components][:chef][:webui][:client_key] = '/etc/chef/webui.pem'
  default[:components][:chef][:webui][:fqdn] = "localhost"
  default[:components][:chef][:webui][:port] = 4000
  default[:components][:chef][:webui][:log_level] = :info
  default[:components][:chef][:webui][:admin_user] = 'admin'
  default[:components][:chef][:webui][:admin_passwd] = 'p@ssw0rd1'
end
