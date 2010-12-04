
include_recipe "webserver"

case node[:platform]
when 'redhat', 'centos', 'fedora'
  # EPEL
  package 'nginx' do
    action :upgrade
  end
end

confdir = '/etc/nginx'

template 'nginx.conf' do
  path '#{confdir}/nginx.conf'
  source 'nginx.conf.erb'
  mode 0544
  owner "root"
  group "root"
end

# servers
node[:components][:webserver][:registry].each { |name,server|
  template "#{name}.nginx.conf" do
    path "#{confdir}/conf.d/#{name}.nginx.conf"
    source 'nginx.conf.d.erb'
    mode 0544
    owner "root"
    group "root"
  end
}

service 'nginx' do
  supports :restart => true, :status =>true
  action [:enable, :start]
end
