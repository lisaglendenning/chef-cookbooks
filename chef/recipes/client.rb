
chef_version = node[:chef_packages][:chef][:version]
chef_version = chef_version.split('.')
chef_version = chef_version[0, 2].join('.')

template "chef-client-config" do
  path node[:components][:chef][:client][:config]
  source "client.#{chef_version}.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :parameters => node[:components][:chef][:client]
  )
end

service "chef-client" do
  supports :restart => true, :status => true
  action :enable
  only_if "[ -f #{node[:components][:chef][:client][:config]} ]"
end

template "chef-client-config-service" do
  path node[:components][:chef][:client][:service_config]
  source "chef-client.#{chef_version}.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :parameters => node[:components][:chef][:client]
  )
  notifies :restart, resources(:service => "chef-client")
end

# remove the validation key once we have a client key
valkey = node[:components][:chef][:client][:validator_key]
clikey = node[:components][:chef][:client][:client_key]
execute "remove-validation" do
  command "if [ -f #{valkey} ]; then rm -f #{valkey}; fi"
  only_if "[ -f #{clikey} ]"
  action :run
end
