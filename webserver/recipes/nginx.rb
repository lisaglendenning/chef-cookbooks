

case node[:platform]
when 'redhat', 'centos', 'fedora'
  # EPEL
  package 'nginx' do
    action :upgrade
  end
end

service 'nginx' do
  supports :restart => true, :status =>true
  action [:enable, :start]
end
