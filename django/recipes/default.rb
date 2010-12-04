
# install

case node[:platform]
when 'redhat', 'centos', 'fedora'
  # Requires EPEL
  package 'Django' do
    action :upgrade
  end
end

# fastcgi requires flup http://www.saddi.com/software/flup/
# EPEL
package 'python-flup' do
  action :upgrade
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
  
  # django service
  name = "django-#{site}"
  service = Mash.new(
    :exec => `which python`.chomp,
    :cwd => "#{root}/#{site}",
    :user => node[:components][:django][:user],
    :group => node[:components][:django][:group],
    :args => ["#{root}/#{site}/manage.py", 
              'runfcgi',
              'protocol=fcgi',
              "socket=#{root}/#{site}/#{name}.sock",
              'daemonize=false',
              'method=threaded'
             ]  
  )
  node[:components][:daemon][:registry][name] = service

  # server
  
  server = { :port => 80 }
  
  # firewall
  
  if node.components.attribute?(:firewall)
    server = Mash.new(:protocol => 'tcp', :port => server[:port])
    node.set[:components][:firewall][:registry]["django-#{site}"] = [server]
  end
}

include_recipe "daemon"
include_recipe "webserver::nginx"

