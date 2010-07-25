
chef_version = node[:chef_packages][:chef][:version]
chef_version = chef_version.split('.')
chef_version = chef_version[0, 2].join('.')

service "chef-server" do
  supports :restart => true, :status => true
  action :enable
  only_if "[ -f #{node[:components][:chef][:server][:config]} ]"
end

template "chef-server-config" do
  path node[:components][:chef][:server][:config]
  source "server.#{chef_version}.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :parameters => node[:components][:chef][:server]
  )
  notifies :restart, resources(:service => "chef-server")
end
