
chef_version = node[:chef_packages][:chef][:version]
chef_version = chef_version.split('.')
chef_version = chef_version[0, 2].join('.')

if node[:components][:chef][:server][:enabled]

  if node.components.attribute?(:firewall)
    server = Mash.new(
      :protocol => 'tcp', 
      :port => node[:components][:chef][:server][:port]
    )
    node.set[:components][:firewall][:registry]['chef-server'] = [server]
  end

  if node[:components][:chef][:install] == :package
    package 'chef-server-api' do
      action :upgrade
    end
  end
  
  services = ['couchdb', 'rabbitmq-server', 'chef-solr', 'chef-solr-indexer', 'chef-server']
  services.each do |svc|
    service svc do
      supports :restart => true, :status => true
      action [:enable, :start]
      only_if "[ -f #{node[:components][:chef][:server][:config]} ]"
    end
  end
  
  template "chef-server-config" do
    path node[:components][:chef][:server][:config]
    source "server.#{chef_version}.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :server => node[:components][:chef][:server]
    )
    notifies :restart, resources(:service => "chef-server")
  end
end


if node[:components][:chef][:webui][:enabled]

  if node.components.attribute?(:firewall)
    server = Mash.new(:protocol => 'tcp', :port => 4040)
    node.set[:components][:firewall][:registry]['chef-webui'] = [server]
  end

  if node[:components][:chef][:install] == :package
    package 'chef-server-webui' do
      action :upgrade
    end
  end
  
  service "chef-server-webui" do
    supports :restart => true, :status => true
    action [:enable, :start]
    only_if "[ -f #{node[:components][:chef][:webui][:config]} ]"
  end
  
  template "chef-webui-config" do
    path node[:components][:chef][:webui][:config]
    source "webui.#{chef_version}.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :webui => node[:components][:chef][:webui]
    )
    notifies :restart, resources(:service => "chef-server-webui")
  end
end
