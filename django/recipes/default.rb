
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
  
  # django server
  name = "django-#{site}"
  args = [
    "#{root}/#{site}/manage.py", 
    'runfcgi',
    'protocol=fcgi',
    "socket=#{root}/#{site}/#{name}.sock",
    'daemonize=false',
    'method=threaded'
  ]  
  service = Mash.new(
    :exec => `which python`.chomp,
    :cwd => "#{root}/#{site}",
    :user => node[:components][:django][:user],
    :group => node[:components][:django][:group],
    :args => args
  )
  node[:components][:daemon][:registry][name] = service

  # web server
  server = Mash.new
  server[:port] = 80
  server[:backend] = :fastcgi
  server[:backend][:socket] = "{root}/#{site}/#{name}.sock"
  node[:components][:webserver][:registry][name] = server
}

include_recipe "daemon"
include_recipe "webserver::nginx"

