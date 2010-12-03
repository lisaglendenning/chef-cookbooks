
# install

case node[:platform]
when 'redhat', 'centos', 'fedora'
  # Requires EPEL
  package 'Django' do
    action :upgrade
  end
end

# install sites

root = node[:components][:django][:root]

directory root do
  path root
  owner node[:components][:django][:user]
  group node[:components][:django][:group]
  mode "0750"
  recursive true
end
    
node[:components][:django][:sites].each { |site,props|
  execute "django-admin #{site}" do
    command "django-admin startproject #{site}"
    cwd root
    user node[:components][:django][:user]
    group node[:components][:django][:group]
    creates "#{root}/#{site}"
    action :run   
  end

  # server
  
  server = { :port => 80 }
  
  # firewall
  
  if node.components.attribute?(:firewall)
    server = Mash.new(:protocol => 'tcp', :port => server[:port])
    node.set[:components][:firewall][:registry]["django-#{site}"] = [server]
  end
}


