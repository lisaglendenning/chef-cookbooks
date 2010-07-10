
chef_version = node[:chef_packages][:chef][:version]
chef_version = chef_version.split('.')
chef_version = chef_version[0, 2].join('.')

template "chef-client-config" do
  path node[:components][:chef][:client][:config]
  source "client.#{chef_version}.erb"
  owner "root"
  group "root"
  mode "0744"
  variables(
    :parameters => node[:components][:chef][:client]
  )
end

service "chef-client" do
  supports :restart => true, :status => true
  action [:enable, :start]
  only_if "[ -f #{node[:components][:chef][:client][:config]} ]"
end

# remove the validation key once we have a client key
execute "remove-validation" do
  command "if [ -f #{node[:components][:chef][:client][:validator_key]} ]; then rm -f #{node[:components][:chef][:client][:validator_key]}; fi"
  only_if "[ -f #{node[:components][:chef][:client][:client_key]} ]"
  action :run
end
