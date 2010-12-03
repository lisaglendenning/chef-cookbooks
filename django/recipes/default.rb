

case node[:platform]
when 'redhat', 'centos', 'fedora'
  # Requires EPEL
  package 'django' do
    action :upgrade
  end
end
