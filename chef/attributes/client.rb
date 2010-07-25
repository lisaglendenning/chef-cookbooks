
include_attribute "chef"

if node[:components][:chef][:client][:enabled]  
  node.default[:components][:chef][:client][:config] = '/etc/chef/client.rb'
  node.default[:components][:chef][:client][:service_config] = '/etc/sysconfig/chef-client'
  node.default[:components][:chef][:client][:validator] = 'chef-validator'
  node.default[:components][:chef][:client][:validator_key] = '/etc/chef/validation.pem'
  node.default[:components][:chef][:client][:client_key] = '/etc/chef/client.pem'
  node.default[:components][:chef][:client][:fqdn] = "localhost"
  node.default[:components][:chef][:client][:port] = 4000
  node.default[:components][:chef][:client][:log_level] = :info
  node.default[:components][:chef][:client][:node] = node[:components][:fqdn]
  node.default[:components][:chef][:client][:splay] = 20 # seconds
  node.default[:components][:chef][:client][:interval] = 1800 # seconds
end
