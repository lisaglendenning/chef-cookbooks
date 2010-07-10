
default[:components][:chef][:client][:config] = '/etc/chef/client.rb'
default[:components][:chef][:client][:validator] = 'chef-validator'
default[:components][:chef][:client][:validator_key] = '/etc/chef/validation.pem'
default[:components][:chef][:client][:client_key] = '/etc/chef/client.pem'
default[:components][:chef][:client][:server] = 'http://127.0.0.1:4000'
default[:components][:chef][:client][:log_level] = :info


