
default[:components][:chef][:server][:config] = '/etc/chef/server.rb'
default[:components][:chef][:client][:service_config] = '/etc/sysconfig/chef-server'
default[:components][:chef][:server][:validator] = 'chef-validator'
default[:components][:chef][:server][:validator_key] = '/etc/chef/certificates/validation.pem'
default[:components][:chef][:server][:server] = "http://#{node[:components][:fqdn]}:4000"
default[:components][:chef][:server][:log_level] = :warn
