
# fastcgi requires flup http://www.saddi.com/software/flup/
# EPEL
package 'python-flup' do
  action :upgrade
end

root = node[:components][:django][:root]

node[:components][:django][:sites].each { |site,props|
  # django server
  name = "django-#{site}"
  args = [
    "#{root}/#{site}/manage.py", 
    'runfcgi',
    'protocol=fcgi',
    "socket=#{root}/#{site}/#{name}.sock",
    'daemonize=false',
    'method=threaded',
    'umask=002'
  ]
  if props.has_key?(:python)
    python = props[:python]
  else
    python = `which python`.chomp
  end
  service = Mash.new(
    :exec => python,
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
  server[:fastcgi] = Mash.new(:socket => "#{root}/#{site}/#{name}.sock")
  node[:components][:webserver][:registry][name] = server
}

include_recipe "daemon"
