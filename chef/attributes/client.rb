
include_attribute "chef"

if node[:components][:chef][:client][:enabled]  
  default[:components][:chef][:client][:config] = '/etc/chef/client.rb'
  default[:components][:chef][:client][:service_config] = '/etc/sysconfig/chef-client'
  default[:components][:chef][:client][:validator] = 'chef-validator'
  default[:components][:chef][:client][:validator_key] = '/etc/chef/validation.pem'
  default[:components][:chef][:client][:client_key] = '/etc/chef/client.pem'
  default[:components][:chef][:client][:fqdn] = "localhost"
  default[:components][:chef][:client][:port] = 4000
  default[:components][:chef][:client][:log_level] = :info
  default[:components][:chef][:client][:node] = node[:components][:fqdn]
  default[:components][:chef][:client][:splay] = 20
  default[:components][:chef][:client][:interval] = 1800
end
